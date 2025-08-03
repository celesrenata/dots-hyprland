# Phase 5: NixOS-Specific Adaptations

## Overview
This phase focuses on adapting dots-hyprland to work seamlessly with NixOS paradigms, replacing Arch-specific elements and integrating with NixOS/Home Manager patterns. Based on the original install script analysis, we need to replace package management, service management, and file handling approaches.

## Arch-Specific Elements to Replace

### From Install Script Analysis (`install.sh`)

#### 1. Package Management Replacement
**Original Arch Approach:**
```bash
# From install.sh
yay -S --needed package1 package2 package3
pacman -Syu
```

**NixOS Replacement:**
```nix
# Declarative package management
home.packages = with pkgs; [
  package1 package2 package3
];

# System packages
environment.systemPackages = with pkgs; [
  system-package1 system-package2
];
```

#### 2. Service Management Replacement
**Original Arch Approach:**
```bash
# Manual service management
systemctl --user enable service-name
systemctl --user start service-name
```

**NixOS Replacement:**
```nix
# Declarative service management
systemd.user.services.service-name = {
  Unit.Description = "Service description";
  Service = {
    ExecStart = "${pkgs.package}/bin/command";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "default.target" ];
};
```

#### 3. Configuration File Management
**Original Arch Approach:**
```bash
# Direct file copying
cp -r .config/hypr ~/.config/
cp .config/quickshell/ii ~/.config/quickshell/
```

**NixOS Replacement:**
```nix
# Declarative configuration management
xdg.configFile = {
  "hypr" = {
    source = ./configs/hypr;
    recursive = true;
  };
  "quickshell/ii" = {
    source = ./configs/quickshell/ii;
    recursive = true;
  };
};
```

## NixOS Integration Patterns

### 1. Flake-Based Architecture

#### Main Flake Structure
```nix
# flake.nix
{
  description = "NixOS dots-hyprland configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    
    # Custom inputs for bleeding-edge packages
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, quickshell, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          hyprland.overlays.default
        ];
      };
    in
    {
      # Package overlays
      overlays.default = final: prev: {
        quickshell = quickshell.packages.${system}.default;
        dots-hyprland-scripts = self.packages.${system}.scripts;
      };

      # NixOS module
      nixosModules.default = import ./modules/nixos.nix;
      
      # Home Manager module
      homeManagerModules.default = import ./modules/home-manager.nix;

      # Packages
      packages.${system} = {
        scripts = pkgs.callPackage ./packages/scripts { };
        themes = pkgs.callPackage ./packages/themes { };
      };

      # Example configurations
      homeConfigurations = {
        example = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeManagerModules.default
            ./examples/basic-config.nix
          ];
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        example = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.default
            ./examples/nixos-config.nix
          ];
        };
      };
    };
}
```

### 2. Home Manager Integration Patterns

#### User-Level Configuration Management
```nix
# modules/home-manager.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland;
in
{
  imports = [ ./components ];

  options.programs.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland desktop environment";
    
    # User-specific options
    user = {
      name = mkOption {
        type = types.str;
        default = config.home.username;
        description = "Username for configuration";
      };
      
      homeDirectory = mkOption {
        type = types.path;
        default = config.home.homeDirectory;
        description = "Home directory path";
      };
    };

    # Configuration management
    configDir = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}";
      description = "Configuration directory";
    };

    cacheDir = mkOption {
      type = types.path;
      default = "${config.xdg.cacheHome}/dots-hyprland";
      description = "Cache directory for generated files";
    };

    dataDir = mkOption {
      type = types.path;
      default = "${config.xdg.dataHome}/dots-hyprland";
      description = "Data directory for persistent files";
    };
  };

  config = mkIf cfg.enable {
    # Ensure XDG directories exist
    xdg.enable = true;
    xdg.userDirs.enable = true;

    # Create cache and data directories
    home.file."${cfg.cacheDir}/.keep".text = "";
    home.file."${cfg.dataDir}/.keep".text = "";

    # Session variables
    home.sessionVariables = {
      DOTS_HYPRLAND_CONFIG = cfg.configDir;
      DOTS_HYPRLAND_CACHE = cfg.cacheDir;
      DOTS_HYPRLAND_DATA = cfg.dataDir;
    };

    # Shell integration
    programs.bash.initExtra = mkIf config.programs.bash.enable ''
      # dots-hyprland shell integration
      export PATH="${cfg.dataDir}/bin:$PATH"
    '';

    programs.zsh.initExtra = mkIf config.programs.zsh.enable ''
      # dots-hyprland shell integration
      export PATH="${cfg.dataDir}/bin:$PATH"
    '';

    programs.fish.shellInit = mkIf config.programs.fish.enable ''
      # dots-hyprland shell integration
      set -gx PATH "${cfg.dataDir}/bin" $PATH
    '';
  };
}
```

### 3. System-Level Integration

#### NixOS System Module
```nix
# modules/nixos.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dots-hyprland;
in
{
  options.services.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland system integration";

    # System-level configuration
    displayManager = mkOption {
      type = types.enum [ "gdm" "sddm" "lightdm" ];
      default = "gdm";
      description = "Display manager to use";
    };

    # Hardware support
    hardware = {
      nvidia = mkEnableOption "NVIDIA GPU support";
      amd = mkEnableOption "AMD GPU support";
      intel = mkEnableOption "Intel GPU support";
      bluetooth = mkEnableOption "Bluetooth support" // { default = true; };
      audio = mkEnableOption "Audio support" // { default = true; };
    };

    # Security
    security = {
      polkit = mkEnableOption "PolicyKit support" // { default = true; };
      keyring = mkEnableOption "GNOME Keyring support" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    # Display manager configuration
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = mkIf (cfg.displayManager == "gdm") {
          enable = true;
          wayland = true;
        };
        sddm = mkIf (cfg.displayManager == "sddm") {
          enable = true;
          wayland.enable = true;
        };
        lightdm = mkIf (cfg.displayManager == "lightdm") {
          enable = true;
        };
      };
    };

    # Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Audio system
    security.rtkit.enable = mkIf cfg.hardware.audio true;
    services.pipewire = mkIf cfg.hardware.audio {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Bluetooth
    hardware.bluetooth.enable = mkIf cfg.hardware.bluetooth true;
    services.blueman.enable = mkIf cfg.hardware.bluetooth true;

    # Network
    networking.networkmanager.enable = true;

    # Security
    security.polkit.enable = mkIf cfg.security.polkit true;
    services.gnome.gnome-keyring.enable = mkIf cfg.security.keyring true;

    # XDG Portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # Fonts
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      material-design-icons
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];

    # GPU support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # NVIDIA specific
    services.xserver.videoDrivers = mkIf cfg.hardware.nvidia [ "nvidia" ];
    hardware.nvidia = mkIf cfg.hardware.nvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
  };
}
```

## Configuration Template System

### 1. Dynamic Configuration Generation

#### Template Processing System
```nix
# lib/templates.nix
{ lib, pkgs }:

let
  processTemplate = template: substitutions:
    lib.replaceStrings
      (map (name: "@${name}@") (lib.attrNames substitutions))
      (lib.attrValues substitutions)
      template;

  generateConfigFromTemplate = { templatePath, outputPath, substitutions }:
    pkgs.runCommand "generate-config" {} ''
      mkdir -p $(dirname $out/${outputPath})
      
      # Process template with substitutions
      ${pkgs.gnused}/bin/sed \
        ${lib.concatMapStringsSep " " 
          (name: "-e 's|@${name}@|${substitutions.${name}}|g'") 
          (lib.attrNames substitutions)} \
        ${templatePath} > $out/${outputPath}
    '';

  # Color substitution system
  applyColorScheme = template: colors:
    processTemplate template (
      lib.mapAttrs' (name: value: 
        lib.nameValuePair "COLOR_${lib.toUpper name}" value
      ) colors
    );
in
{
  inherit processTemplate generateConfigFromTemplate applyColorScheme;
}
```

### 2. User Customization System

#### User Override Mechanism
```nix
# modules/components/customization.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.customization;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.customization = {
    enable = mkEnableOption "User customization support" // { default = true; };

    # Custom configuration files
    customConfigs = mkOption {
      type = types.attrsOf types.path;
      default = {};
      description = "Custom configuration files to override defaults";
      example = {
        "hypr/hyprland.conf" = ./my-hyprland.conf;
        "quickshell/ii/shell.qml" = ./my-shell.qml;
      };
    };

    # Custom scripts
    customScripts = mkOption {
      type = types.attrsOf types.path;
      default = {};
      description = "Custom scripts to add or override";
      example = {
        "color-generator" = ./my-color-script.py;
        "startup-hook" = ./my-startup.sh;
      };
    };

    # Environment variables
    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Custom environment variables";
      example = {
        "CUSTOM_THEME_PATH" = "/path/to/themes";
        "AI_MODEL_PREFERENCE" = "llama2";
      };
    };

    # Hooks
    hooks = {
      preStart = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run before starting dots-hyprland";
      };

      postStart = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run after starting dots-hyprland";
      };

      colorChange = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run when colors change";
      };
    };
  };

  config = mkIf cfg.enable {
    # Apply custom configurations
    xdg.configFile = lib.mapAttrs' (name: path:
      lib.nameValuePair name { source = path; }
    ) cfg.customConfigs;

    # Install custom scripts
    home.file = lib.mapAttrs' (name: path:
      lib.nameValuePair "${mainCfg.dataDir}/bin/${name}" {
        source = path;
        executable = true;
      }
    ) cfg.customScripts;

    # Apply environment variables
    home.sessionVariables = cfg.environmentVariables;

    # Create hook scripts
    home.file."${mainCfg.dataDir}/hooks/pre-start.sh" = mkIf (cfg.hooks.preStart != "") {
      text = ''
        #!/usr/bin/env bash
        ${cfg.hooks.preStart}
      '';
      executable = true;
    };

    home.file."${mainCfg.dataDir}/hooks/post-start.sh" = mkIf (cfg.hooks.postStart != "") {
      text = ''
        #!/usr/bin/env bash
        ${cfg.hooks.postStart}
      '';
      executable = true;
    };

    home.file."${mainCfg.dataDir}/hooks/color-change.sh" = mkIf (cfg.hooks.colorChange != "") {
      text = ''
        #!/usr/bin/env bash
        ${cfg.hooks.colorChange}
      '';
      executable = true;
    };
  };
}
```

## Service Management Adaptation

### 1. Systemd User Services

#### Service Definition Pattern
```nix
# lib/services.nix
{ lib, pkgs }:

let
  createUserService = { name, description, execStart, dependencies ? [], environment ? {}, restart ? "on-failure" }:
    {
      Unit = {
        Description = description;
        After = dependencies;
        Wants = dependencies;
      };

      Service = {
        Type = "simple";
        ExecStart = execStart;
        Restart = restart;
        RestartSec = 1;
        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") environment;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

  createOneTimeService = { name, description, execStart, dependencies ? [], environment ? {} }:
    {
      Unit = {
        Description = description;
        After = dependencies;
        Wants = dependencies;
      };

      Service = {
        Type = "oneshot";
        ExecStart = execStart;
        RemainAfterExit = true;
        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") environment;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
in
{
  inherit createUserService createOneTimeService;
}
```

### 2. Session Target Management

#### Hyprland Session Integration
```nix
# modules/components/session.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.session;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.session = {
    enable = mkEnableOption "Session management" // { default = true; };

    target = mkOption {
      type = types.str;
      default = "hyprland-session.target";
      description = "Systemd target for the session";
    };

    autoStart = mkOption {
      type = types.listOf types.str;
      default = [ "quickshell" "hypridle" ];
      description = "Services to start automatically";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Session environment variables";
    };
  };

  config = mkIf cfg.enable {
    # Create session target
    systemd.user.targets."${cfg.target}" = {
      Unit = {
        Description = "dots-hyprland session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    # Session environment
    systemd.user.services."${cfg.target}-env" = {
      Unit = {
        Description = "Set up dots-hyprland session environment";
        Before = [ cfg.target ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-session-env" ''
          # Set up session environment
          ${lib.concatMapStringsSep "\n" (name: 
            "export ${name}='${cfg.environment.${name}}'"
          ) (lib.attrNames cfg.environment)}
          
          # Create necessary directories
          mkdir -p "${mainCfg.cacheDir}"
          mkdir -p "${mainCfg.dataDir}"
          
          # Run pre-start hooks
          if [[ -x "${mainCfg.dataDir}/hooks/pre-start.sh" ]]; then
            "${mainCfg.dataDir}/hooks/pre-start.sh"
          fi
        '';
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = [ cfg.target ];
      };
    };

    # Auto-start services
    systemd.user.services = lib.genAttrs cfg.autoStart (serviceName: {
      Install = {
        WantedBy = [ cfg.target ];
      };
    });
  };
}
```

## Package Management Adaptation

### 1. Declarative Package Lists

#### Package Categories
```nix
# lib/packages.nix
{ lib, pkgs }:

let
  # Core system packages
  corePackages = with pkgs; [
    # Basic utilities
    coreutils findutils gnused gnugrep gawk
    curl wget rsync axel
    jq ripgrep fd
    
    # Development tools
    git cmake meson ninja pkg-config
    
    # System integration
    xdg-user-dirs xdg-utils
    polkit polkit-kde-agent
  ];

  # Hyprland ecosystem
  hyprlandPackages = with pkgs; [
    hyprland hyprland-qtutils
    hypridle hyprlock hyprpicker hyprsunset
    hyprutils hyprlang hyprcursor
    hyprwayland-scanner
    xdg-desktop-portal-hyprland
    wl-clipboard wl-clip-persist
  ];

  # Widget system packages
  widgetPackages = with pkgs; [
    quickshell
    fuzzel wlogout
    libnotify dunst
    glib # for gsettings
  ];

  # Audio packages
  audioPackages = with pkgs; [
    pipewire wireplumber
    pavucontrol pwvucontrol
    playerctl
  ];

  # Theme packages
  themePackages = with pkgs; [
    matugen
    material-color-utilities
    adwaita-icon-theme
    gnome.adwaita-icon-theme
    papirus-icon-theme
  ];

  # Development packages
  developmentPackages = with pkgs; [
    python3 python3Packages.pip
    nodejs npm
    qt6.full
  ];

  # Application packages
  applicationPackages = with pkgs; [
    foot kitty # terminals
    firefox chromium # browsers
    nautilus # file manager
    code # editor
    discord # communication
  ];

  # Font packages
  fontPackages = with pkgs; [
    noto-fonts noto-fonts-cjk noto-fonts-emoji
    font-awesome material-design-icons
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
  ];
in
{
  inherit 
    corePackages hyprlandPackages widgetPackages 
    audioPackages themePackages developmentPackages
    applicationPackages fontPackages;
    
  # Combined package sets
  essentialPackages = corePackages ++ hyprlandPackages ++ widgetPackages;
  fullPackages = essentialPackages ++ audioPackages ++ themePackages ++ applicationPackages ++ fontPackages;
  
  # Development environment
  devPackages = developmentPackages ++ corePackages;
}
```

### 2. Conditional Package Installation

#### Feature-Based Package Selection
```nix
# modules/components/packages.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.packages;
  mainCfg = config.programs.dots-hyprland;
  packageLib = import ../lib/packages.nix { inherit lib pkgs; };
in
{
  options.programs.dots-hyprland.packages = {
    enable = mkEnableOption "Package management" // { default = true; };

    sets = {
      core = mkEnableOption "Core packages" // { default = true; };
      hyprland = mkEnableOption "Hyprland ecosystem packages" // { default = true; };
      widgets = mkEnableOption "Widget system packages" // { default = true; };
      audio = mkEnableOption "Audio packages" // { default = true; };
      themes = mkEnableOption "Theme packages" // { default = true; };
      applications = mkEnableOption "Application packages";
      fonts = mkEnableOption "Font packages" // { default = true; };
      development = mkEnableOption "Development packages";
    };

    extra = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Package names to exclude from installation";
    };
  };

  config = mkIf cfg.enable {
    home.packages = 
      (optionals cfg.sets.core packageLib.corePackages) ++
      (optionals cfg.sets.hyprland packageLib.hyprlandPackages) ++
      (optionals cfg.sets.widgets packageLib.widgetPackages) ++
      (optionals cfg.sets.audio packageLib.audioPackages) ++
      (optionals cfg.sets.themes packageLib.themePackages) ++
      (optionals cfg.sets.applications packageLib.applicationPackages) ++
      (optionals cfg.sets.fonts packageLib.fontPackages) ++
      (optionals cfg.sets.development packageLib.developmentPackages) ++
      cfg.extra;

    # Filter out excluded packages
    home.packages = lib.filter (pkg: 
      !(lib.elem pkg.pname cfg.exclude)
    ) config.home.packages;
  };
}
```

## Action Items for Phase 5

### Week 1: Core Adaptations
1. **Replace package management** - Convert from yay/pacman to Nix
2. **Adapt service management** - Convert to systemd user services
3. **Update configuration management** - Use xdg.configFile patterns
4. **Test basic integration** - Ensure NixOS patterns work

### Week 2: Advanced Integration
1. **Implement template system** - Dynamic configuration generation
2. **Add user customization** - Override mechanisms
3. **Create session management** - Proper systemd targets
4. **Test complex scenarios** - Multiple users, different hardware

### Week 3: Polish & Optimization
1. **Performance optimization** - Reduce startup time, memory usage
2. **Error handling** - Graceful failure modes
3. **Documentation** - NixOS-specific usage patterns
4. **Testing** - Comprehensive integration tests

## Expected Outcomes

### Deliverables
1. **Complete NixOS integration** - All Arch-specific elements replaced
2. **Declarative configuration** - Everything managed through Nix
3. **User customization system** - Easy override mechanisms
4. **Service management** - Proper systemd integration
5. **Package management** - Feature-based package selection
6. **Template system** - Dynamic configuration generation

### Success Criteria
- [ ] No Arch-specific dependencies remain
- [ ] All services managed through systemd user services
- [ ] Configuration fully declarative and reproducible
- [ ] User customization works seamlessly
- [ ] Package management is feature-based and flexible
- [ ] Template system generates correct configurations
- [ ] Integration with NixOS and Home Manager is seamless
- [ ] Ready for Phase 6 (Testing & Validation)
