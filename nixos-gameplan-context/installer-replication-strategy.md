# Installer Replication Strategy

## Overview
Based on our complete analysis of the original dots-hyprland installer, we now have a clear roadmap for creating a NixOS implementation that replicates the installer's behavior exactly, without the complexity of FHS environments.

## Core Principle: Direct Installer Replication

**Strategy**: Replicate each step of the original installer using NixOS/Home Manager patterns, maintaining the exact same end result but using declarative configuration.

## Implementation Architecture

### 1. Package Management Layer

#### NixOS Package Mapping
```nix
# packages/dots-hyprland-packages.nix
{ lib, pkgs }:

let
  # Direct mapping from PKGBUILD files
  basicPackages = with pkgs; [
    axel bc coreutils cliphist cmake curl rsync wget ripgrep jq meson xdg-user-dirs
  ];

  widgetPackages = with pkgs; [
    fuzzel glib hypridle hyprutils hyprlock hyprpicker networkmanagerapplet
    quickshell translate-shell wlogout
  ];

  hyprlandPackages = with pkgs; [
    hypridle hyprcursor hyprland hyprland-qtutils hyprlang hyprlock hyprpicker
    hyprsunset hyprutils hyprwayland-scanner xdg-desktop-portal-hyprland wl-clipboard
  ];

  pythonSystemPackages = with pkgs; [
    clang uv gtk4 libadwaita libsoup3 libportal-gtk4 gobject-introspection
    sassc opencv4
  ];
in
{
  inherit basicPackages widgetPackages hyprlandPackages pythonSystemPackages;
  
  allPackages = basicPackages ++ widgetPackages ++ hyprlandPackages ++ pythonSystemPackages;
}
```

### 2. Python Virtual Environment Layer

#### Exact Python Environment Replication
```nix
# modules/python-environment.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dots-hyprland.python;
  
  # Exact requirements from scriptdata/requirements.txt
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    build
    cffi
    libsass
    material-color-utilities
    materialyoucolor
    numpy
    packaging
    pillow
    psutil
    pycparser
    pyproject-hooks
    pywayland
    setproctitle
    setuptools
    setuptools-scm
    wheel
  ]);

  # Virtual environment setup script
  setupVenvScript = pkgs.writeShellScript "setup-dots-hyprland-venv" ''
    #!/usr/bin/env bash
    
    VENV_PATH="$HOME/.local/state/quickshell/.venv"
    
    echo "Setting up dots-hyprland Python virtual environment..."
    
    # Create directory
    mkdir -p "$(dirname "$VENV_PATH")"
    
    # Create virtual environment with Python 3.12
    ${pkgs.python312}/bin/python -m venv "$VENV_PATH" --prompt .venv
    
    # Install exact requirements
    "$VENV_PATH/bin/pip" install \
      build==1.2.2.post1 \
      cffi==1.17.1 \
      libsass==0.23.0 \
      material-color-utilities==0.2.1 \
      materialyoucolor==2.0.10 \
      numpy==2.2.2 \
      packaging==24.2 \
      pillow==11.1.0 \
      psutil==6.1.1 \
      pycparser==2.22 \
      pyproject-hooks==1.2.0 \
      pywayland==0.4.18 \
      setproctitle==1.3.4 \
      setuptools==80.9.0 \
      setuptools-scm==8.1.0 \
      wheel==0.45.1
    
    echo "✅ Python virtual environment setup complete"
  '';
in
{
  options.programs.dots-hyprland.python = {
    enable = mkEnableOption "Python virtual environment for dots-hyprland";
    
    venvPath = mkOption {
      type = types.str;
      default = "$HOME/.local/state/quickshell/.venv";
      description = "Path to Python virtual environment";
    };
  };

  config = mkIf cfg.enable {
    # Install system Python packages
    home.packages = with pkgs; [
      python312
      python312Packages.pip
      python312Packages.virtualenv
    ];

    # Set up virtual environment on activation
    home.activation.setupDotsHyprlandVenv = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${setupVenvScript}
    '';

    # Set environment variable
    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = cfg.venvPath;
    };
  };
}
```

### 3. Configuration Management Layer

#### Clean Upstream Source Integration
```nix
# modules/configuration.nix
{ config, lib, pkgs, dots-hyprland-source, ... }:

let
  cfg = config.programs.dots-hyprland.configuration;
in
{
  options.programs.dots-hyprland.configuration = {
    enable = mkEnableOption "dots-hyprland configuration management";
    
    source = mkOption {
      type = types.path;
      default = dots-hyprland-source;
      description = "Source path for dots-hyprland configuration";
    };
  };

  config = mkIf cfg.enable {
    # Copy all .config/* except fish and hypr (replicating installer logic)
    xdg.configFile = 
      let
        configDirs = [
          "quickshell" "kitty" "foot" "fuzzel" "wlogout" "matugen"
          # Add other config directories as needed
        ];
        
        configFiles = lib.listToAttrs (map (dir: {
          name = dir;
          value = {
            source = "${cfg.source}/.config/${dir}";
            recursive = true;
          };
        }) configDirs);
      in
      configFiles // {
        # Special handling for hypr (excluding custom/, hyprlock.conf, etc.)
        "hypr" = {
          source = pkgs.runCommand "hypr-config" {} ''
            mkdir -p $out
            cp -r ${cfg.source}/.config/hypr/* $out/
            
            # Remove excluded files (replicating installer --exclude logic)
            rm -rf $out/custom $out/hyprlock.conf $out/hypridle.conf $out/hyprland.conf
          '';
          recursive = true;
        };
        
        # Copy hyprland.conf separately (installer does this)
        "hypr/hyprland.conf".source = "${cfg.source}/.config/hypr/hyprland.conf";
        "hypr/hypridle.conf".source = "${cfg.source}/.config/hypr/hypridle.conf";
        "hypr/hyprlock.conf".source = "${cfg.source}/.config/hypr/hyprlock.conf";
      };

    # Copy .local/share files (replicating installer)
    home.file = {
      ".local/share/icons" = {
        source = "${cfg.source}/.local/share/icons";
        recursive = true;
      };
      ".local/share/konsole" = {
        source = "${cfg.source}/.local/share/konsole";
        recursive = true;
      };
    };
  };
}
```

### 4. System Integration Layer

#### NixOS System Configuration
```nix
# modules/system-integration.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dots-hyprland.system;
in
{
  options.programs.dots-hyprland.system = {
    enable = mkEnableOption "System-level integration for dots-hyprland";
    
    userGroups = mkOption {
      type = types.listOf types.str;
      default = [ "video" "i2c" "input" ];
      description = "User groups to add the user to";
    };
  };

  config = mkIf cfg.enable {
    # User groups (replicating: sudo usermod -aG video,i2c,input)
    users.users.${config.home.username}.extraGroups = cfg.userGroups;

    # System services (replicating installer)
    systemd.services.bluetooth.enable = true;
    
    # i2c module loading (replicating: echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf)
    boot.kernelModules = [ "i2c-dev" ];

    # User services
    systemd.user.services.ydotool = {
      enable = true;
      wantedBy = [ "default.target" ];
    };

    # Desktop settings (replicating gsettings and kwriteconfig6)
    home.activation.setupDesktopSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface font-name 'Rubik 11'
      $DRY_RUN_CMD ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      
      # KDE settings (if KDE is available)
      if command -v kwriteconfig6 >/dev/null 2>&1; then
        $DRY_RUN_CMD kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly
      fi
    '';
  };
}
```

### 5. Main Module Integration

#### Complete dots-hyprland Module
```nix
# modules/home-manager.nix
{ config, lib, pkgs, dots-hyprland-source, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland;
in
{
  imports = [
    ./python-environment.nix
    ./configuration.nix
    ./system-integration.nix
  ];

  options.programs.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland desktop environment";
    
    source = mkOption {
      type = types.path;
      default = dots-hyprland-source;
      description = "Source path for dots-hyprland";
    };
  };

  config = mkIf cfg.enable {
    # Install all required packages
    home.packages = (import ../packages/dots-hyprland-packages.nix { inherit lib pkgs; }).allPackages;

    # Enable all components
    programs.dots-hyprland.python.enable = true;
    programs.dots-hyprland.configuration.enable = true;
    programs.dots-hyprland.system.enable = true;

    # Set critical environment variable
    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "$HOME/.local/state/quickshell/.venv";
    };

    # Ensure XDG directories exist
    xdg.enable = true;
    xdg.userDirs.enable = true;
  };
}
```

## Implementation Timeline

### Week 1: Core Infrastructure
1. **Package mapping** - Map all PKGBUILD dependencies to nixpkgs
2. **Python environment** - Set up exact virtual environment replication
3. **Basic module structure** - Create foundational modules

### Week 2: Configuration Management
1. **Source integration** - Set up clean upstream source copying
2. **Environment variables** - Ensure all required variables are set
3. **File permissions** - Handle executable scripts and permissions

### Week 3: System Integration
1. **User groups and services** - Replicate system-level setup
2. **Desktop settings** - Handle gsettings and KDE configuration
3. **Testing** - Verify complete installer replication

### Week 4: Validation & Polish
1. **End-to-end testing** - Compare with original installer results
2. **Edge case handling** - Handle missing dependencies gracefully
3. **Documentation** - Document the replication approach

## Success Criteria

- [ ] All packages from meta-packages available in NixOS
- [ ] Python virtual environment created with exact requirements
- [ ] Configuration files copied exactly as installer does
- [ ] Environment variables set correctly
- [ ] System integration (groups, services) working
- [ ] quickshell loads without QML module errors
- [ ] All Python scripts can find their dependencies
- [ ] Desktop environment fully functional

## Key Advantages of This Approach

1. **Exact Replication** - Mirrors installer behavior precisely
2. **No FHS Complexity** - Uses standard NixOS patterns
3. **Maintainable** - Clear separation of concerns
4. **Updatable** - Easy to update upstream source
5. **Debuggable** - Each layer can be tested independently
6. **Reproducible** - Declarative configuration ensures consistency

This strategy provides a clear path to a working dots-hyprland implementation that maintains the original's functionality while leveraging NixOS's strengths.
