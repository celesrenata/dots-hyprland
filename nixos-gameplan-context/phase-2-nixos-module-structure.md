# Phase 2: NixOS Module Structure

## Overview
This phase designs the NixOS module architecture for dots-hyprland, focusing on creating a modular, configurable, and maintainable system that integrates seamlessly with NixOS and Home Manager.

## Module Architecture Design

### Directory Structure
Based on the original repo structure and NixOS best practices:

```
nixos-dots-hyprland/
├── flake.nix                           # Main flake with outputs
├── flake.lock                          # Lock file
├── README.md                           # Documentation
├── modules/
│   ├── default.nix                     # Main module entry point
│   ├── home-manager.nix                # Home Manager integration
│   ├── nixos.nix                       # NixOS system integration
│   └── components/
│       ├── hyprland.nix                # Hyprland configuration
│       ├── quickshell.nix              # Quickshell widget system
│       ├── theming.nix                 # Material You theming
│       ├── applications.nix            # Application configurations
│       ├── services.nix                # System services
│       ├── ai.nix                      # AI integration (Gemini/Ollama)
│       ├── audio.nix                   # Audio system configuration
│       ├── fonts.nix                   # Font configuration
│       └── development.nix             # Development tools
├── packages/
│   ├── default.nix                     # Package overlay
│   ├── quickshell/                     # Custom quickshell derivation
│   │   ├── default.nix
│   │   └── quickshell.patch            # If needed
│   ├── material-color-utilities/       # Color generation tools
│   │   └── default.nix
│   └── scripts/                        # Custom scripts as packages
│       ├── color-generator.nix
│       ├── ai-helper.nix
│       └── system-integration.nix
├── configs/                            # Configuration templates
│   ├── hypr/                           # Hyprland configurations
│   │   ├── hyprland.conf.template
│   │   ├── hypridle.conf.template
│   │   ├── hyprlock.conf.template
│   │   └── rules.conf.template
│   ├── quickshell/                     # Quickshell configurations
│   │   ├── ii/                         # illogical-impulse style
│   │   │   ├── shell.qml.template
│   │   │   ├── settings.qml.template
│   │   │   ├── modules/                # Widget modules
│   │   │   ├── services/               # Service definitions
│   │   │   └── scripts/                # Helper scripts
│   │   └── translations/               # Translation files
│   ├── applications/                   # App-specific configs
│   │   ├── foot.ini.template
│   │   ├── kitty.conf.template
│   │   ├── fuzzel.ini.template
│   │   └── wlogout/
│   └── themes/                         # Theme templates
│       ├── material-you/
│       └── kvantum/
├── assets/                             # Static assets
│   ├── icons/                          # Custom icons
│   ├── images/                         # Wallpapers, backgrounds
│   └── sounds/                         # System sounds
└── lib/                                # Utility functions
    ├── default.nix                     # Library functions
    ├── colors.nix                      # Color generation utilities
    ├── templates.nix                   # Template processing
    └── validation.nix                  # Configuration validation
```

## Core Module Design

### Main Module Entry Point (`modules/default.nix`)
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland;
in
{
  imports = [
    ./components/hyprland.nix
    ./components/quickshell.nix
    ./components/theming.nix
    ./components/applications.nix
    ./components/services.nix
    ./components/ai.nix
    ./components/audio.nix
    ./components/fonts.nix
  ];

  options.programs.dots-hyprland = {
    enable = mkEnableOption "end-4's dots-hyprland configuration";

    style = mkOption {
      type = types.enum [ "illogical-impulse" ];
      default = "illogical-impulse";
      description = "The style variant to use";
    };

    components = {
      hyprland = mkEnableOption "Hyprland window manager" // { default = true; };
      quickshell = mkEnableOption "Quickshell widget system" // { default = true; };
      theming = mkEnableOption "Material You theming" // { default = true; };
      ai = mkEnableOption "AI integration (Gemini/Ollama)";
      audio = mkEnableOption "Audio system integration" // { default = true; };
      development = mkEnableOption "Development tools and utilities";
    };

    features = {
      overview = mkEnableOption "Overview/launcher widget" // { default = true; };
      sidebar = mkEnableOption "Left and right sidebars" // { default = true; };
      notifications = mkEnableOption "Notification system" // { default = true; };
      mediaControls = mkEnableOption "Media control widgets" // { default = true; };
      screenCorners = mkEnableOption "Screen corner interactions";
      onScreenKeyboard = mkEnableOption "On-screen keyboard";
      cheatsheet = mkEnableOption "Keybind cheatsheet" // { default = true; };
    };

    theming = {
      wallpaper = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to wallpaper for Material You color generation";
      };

      colorScheme = mkOption {
        type = types.nullOr (types.enum [ "light" "dark" "auto" ]);
        default = "auto";
        description = "Color scheme preference";
      };

      accentColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Custom accent color (hex format)";
      };
    };

    ai = {
      gemini = {
        enable = mkEnableOption "Google Gemini AI integration";
        apiKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to file containing Gemini API key";
        };
      };

      ollama = {
        enable = mkEnableOption "Ollama local AI integration";
        endpoint = mkOption {
          type = types.str;
          default = "http://localhost:11434";
          description = "Ollama API endpoint";
        };
        models = mkOption {
          type = types.listOf types.str;
          default = [ "llama2" ];
          description = "List of Ollama models to use";
        };
      };
    };

    keybinds = {
      modifier = mkOption {
        type = types.str;
        default = "SUPER";
        description = "Main modifier key";
      };

      terminal = mkOption {
        type = types.str;
        default = "foot";
        description = "Default terminal emulator";
      };

      launcher = mkOption {
        type = types.str;
        default = "${cfg.keybinds.modifier}";
        description = "Keybind to open launcher/overview";
      };

      cheatsheet = mkOption {
        type = types.str;
        default = "${cfg.keybinds.modifier}_SLASH";
        description = "Keybind to show cheatsheet";
      };
    };
  };

  config = mkIf cfg.enable {
    # Import component configurations
    programs.dots-hyprland.hyprland = mkIf cfg.components.hyprland { enable = true; };
    programs.dots-hyprland.quickshell = mkIf cfg.components.quickshell { enable = true; };
    programs.dots-hyprland.theming = mkIf cfg.components.theming { enable = true; };
    programs.dots-hyprland.ai = mkIf cfg.components.ai { enable = true; };
    programs.dots-hyprland.audio = mkIf cfg.components.audio { enable = true; };

    # Ensure required packages are available
    home.packages = with pkgs; [
      # Core utilities from Phase 1 analysis
      axel bc coreutils cliphist cmake curl rsync wget ripgrep jq meson xdg-user-dirs
      
      # Custom packages
      quickshell
      material-color-utilities
    ];
  };
}
```

### Hyprland Component (`modules/components/hyprland.nix`)
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.hyprland;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.hyprland = {
    enable = mkEnableOption "Hyprland configuration for dots-hyprland";

    animations = mkEnableOption "Hyprland animations" // { default = true; };
    blur = mkEnableOption "Window blur effects";
    
    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor name";
          };
          resolution = mkOption {
            type = types.str;
            default = "preferred";
            description = "Monitor resolution";
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
            description = "Monitor refresh rate";
          };
          position = mkOption {
            type = types.str;
            default = "auto";
            description = "Monitor position";
          };
        };
      });
      default = [];
      description = "Monitor configuration";
    };

    workspaces = mkOption {
      type = types.int;
      default = 10;
      description = "Number of workspaces";
    };

    customConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Hyprland configuration";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      
      settings = {
        # Based on original hyprland.conf analysis
        "$mod" = mainCfg.keybinds.modifier;
        
        monitor = map (m: "${m.name},${m.resolution}@${toString m.refreshRate},${m.position},1") cfg.monitors;
        
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "$accent";
          "col.inactive_border" = "$surface";
          layout = "dwindle";
        };

        decoration = {
          rounding = 12;
          blur = mkIf cfg.blur {
            enabled = true;
            size = 6;
            passes = 3;
            new_optimizations = true;
          };
          drop_shadow = true;
          shadow_range = 30;
          shadow_render_power = 3;
          "col.shadow" = "0x66000000";
        };

        animations = mkIf cfg.animations {
          enabled = true;
          bezier = [
            "materialEaseInOut,0.4, 0, 0.2, 1"
            "materialEaseIn,0.4, 0, 1, 1"
            "materialEaseOut,0, 0, 0.2, 1"
          ];
          animation = [
            "windows,1,3,materialEaseInOut,slide"
            "border,1,10,default"
            "fade,1,2,materialEaseInOut"
            "workspaces,1,3,materialEaseInOut,slide"
          ];
        };

        # Keybinds based on original configuration
        bind = [
          "$mod, Return, exec, ${mainCfg.keybinds.terminal}"
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, E, exec, nautilus"
          "$mod, V, togglefloating"
          "$mod, slash, exec, quickshell -c cheatsheet"
          
          # Workspace switching
        ] ++ (map (i: "$mod, ${toString i}, workspace, ${toString i}") (range 1 cfg.workspaces))
          ++ (map (i: "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}") (range 1 cfg.workspaces));

        # Window rules
        windowrule = [
          "float,^(pavucontrol)$"
          "float,^(nm-connection-editor)$"
          "float,^(blueman-manager)$"
        ];
      };

      extraConfig = cfg.customConfig;
    };

    # Additional Hyprland ecosystem packages
    home.packages = with pkgs; [
      hypridle
      hyprlock
      hyprpicker
      hyprsunset
      hyprutils
      xdg-desktop-portal-hyprland
      wl-clipboard
    ];

    # Configuration files
    xdg.configFile = {
      "hypr/hypridle.conf".source = ../configs/hypr/hypridle.conf.template;
      "hypr/hyprlock.conf".source = ../configs/hypr/hyprlock.conf.template;
    };
  };
}
```

### Quickshell Component (`modules/components/quickshell.nix`)
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.quickshell;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.quickshell = {
    enable = mkEnableOption "Quickshell widget system";

    modules = {
      bar = mkEnableOption "Top bar" // { default = true; };
      overview = mkEnableOption "Overview/launcher" // { default = true; };
      sidebarLeft = mkEnableOption "Left sidebar" // { default = true; };
      sidebarRight = mkEnableOption "Right sidebar" // { default = true; };
      notifications = mkEnableOption "Notification popups" // { default = true; };
      mediaControls = mkEnableOption "Media control widgets" // { default = true; };
      onScreenDisplay = mkEnableOption "Volume/brightness OSD" // { default = true; };
      cheatsheet = mkEnableOption "Keybind cheatsheet" // { default = true; };
      dock = mkEnableOption "Application dock";
      screenCorners = mkEnableOption "Screen corner interactions";
      onScreenKeyboard = mkEnableOption "Virtual keyboard";
      session = mkEnableOption "Session management widgets";
      lock = mkEnableOption "Lock screen integration";
    };

    scaling = mkOption {
      type = types.float;
      default = 1.0;
      description = "UI scaling factor";
    };

    language = mkOption {
      type = types.str;
      default = "en_US";
      description = "Interface language";
    };

    customConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Quickshell configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      quickshell
      fuzzel  # launcher backend
      wlogout # session management
      translate-shell # for translations
    ];

    # Generate shell.qml based on enabled modules
    xdg.configFile."quickshell/ii/shell.qml".text = ''
      //@ pragma UseQApplication
      //@ pragma Env QS_NO_RELOAD_POPUP=1
      //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
      //@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
      //@ pragma Env QT_SCALE_FACTOR=${toString cfg.scaling}

      import "./modules/common/"
      ${optionalString cfg.modules.bar ''import "./modules/bar/"''}
      ${optionalString cfg.modules.overview ''import "./modules/overview/"''}
      ${optionalString cfg.modules.sidebarLeft ''import "./modules/sidebarLeft/"''}
      ${optionalString cfg.modules.sidebarRight ''import "./modules/sidebarRight/"''}
      ${optionalString cfg.modules.notifications ''import "./modules/notificationPopup/"''}
      ${optionalString cfg.modules.mediaControls ''import "./modules/mediaControls/"''}
      ${optionalString cfg.modules.onScreenDisplay ''import "./modules/onScreenDisplay/"''}
      ${optionalString cfg.modules.cheatsheet ''import "./modules/cheatsheet/"''}
      ${optionalString cfg.modules.dock ''import "./modules/dock/"''}
      ${optionalString cfg.modules.screenCorners ''import "./modules/screenCorners/"''}
      ${optionalString cfg.modules.onScreenKeyboard ''import "./modules/onScreenKeyboard/"''}
      ${optionalString cfg.modules.session ''import "./modules/session/"''}
      ${optionalString cfg.modules.lock ''import "./modules/lock/"''}

      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts
      import QtQuick.Window
      import Quickshell
      import "./services/"

      ShellRoot {
          property bool enableBar: ${boolToString cfg.modules.bar}
          property bool enableOverview: ${boolToString cfg.modules.overview}
          property bool enableSidebarLeft: ${boolToString cfg.modules.sidebarLeft}
          property bool enableSidebarRight: ${boolToString cfg.modules.sidebarRight}
          property bool enableNotificationPopup: ${boolToString cfg.modules.notifications}
          property bool enableMediaControls: ${boolToString cfg.modules.mediaControls}
          property bool enableOnScreenDisplayBrightness: ${boolToString cfg.modules.onScreenDisplay}
          property bool enableOnScreenDisplayVolume: ${boolToString cfg.modules.onScreenDisplay}
          property bool enableCheatsheet: ${boolToString cfg.modules.cheatsheet}
          property bool enableDock: ${boolToString cfg.modules.dock}
          property bool enableScreenCorners: ${boolToString cfg.modules.screenCorners}
          property bool enableOnScreenKeyboard: ${boolToString cfg.modules.onScreenKeyboard}
          property bool enableSession: ${boolToString cfg.modules.session}
          property bool enableLock: ${boolToString cfg.modules.lock}

          ${cfg.customConfig}
      }
    '';

    # Copy all Quickshell configuration files
    xdg.configFile."quickshell/ii" = {
      source = ../configs/quickshell/ii;
      recursive = true;
    };

    # Language configuration
    xdg.configFile."quickshell/translations/${cfg.language}.json" = {
      source = ../configs/quickshell/translations + "/${cfg.language}.json";
    };

    # Systemd service for Quickshell
    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell - QtQuick based desktop shell";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
```

## Integration Strategy

### Home Manager Integration (`modules/home-manager.nix`)
```nix
{ config, lib, pkgs, ... }:

{
  imports = [ ./default.nix ];

  # Home Manager specific configurations
  config = lib.mkIf config.programs.dots-hyprland.enable {
    # Ensure XDG directories are set up
    xdg.enable = true;
    xdg.userDirs.enable = true;

    # Session variables
    home.sessionVariables = {
      QT_SCALE_FACTOR = toString config.programs.dots-hyprland.quickshell.scaling;
      QT_QUICK_CONTROLS_STYLE = "Basic";
    };

    # Desktop entries for applications
    xdg.desktopEntries = {
      dots-hyprland-settings = {
        name = "illogical-impulse Settings";
        comment = "Configure dots-hyprland";
        exec = "quickshell -c settings";
        icon = "preferences-system";
        categories = [ "Settings" ];
      };
    };
  };
}
```

### NixOS System Integration (`modules/nixos.nix`)
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dots-hyprland;
in
{
  options.services.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland system integration";
  };

  config = mkIf cfg.enable {
    # Enable required system services
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;

    # Hyprland
    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

    # Audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Network
    networking.networkmanager.enable = true;

    # Fonts
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      material-design-icons
    ];

    # Security
    security.polkit.enable = true;
    security.pam.services.hyprlock = {};

    # XDG Portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };
}
```

## Flake Structure

### Main Flake (`flake.nix`)
```nix
{
  description = "NixOS configuration for end-4's dots-hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      # Package overlay
      overlays.default = import ./packages;

      # Home Manager module
      homeManagerModules.default = import ./modules/home-manager.nix;
      homeManagerModules.dots-hyprland = self.homeManagerModules.default;

      # NixOS module
      nixosModules.default = import ./modules/nixos.nix;
      nixosModules.dots-hyprland = self.nixosModules.default;

      # Packages
      packages.${system} = {
        quickshell = pkgs.callPackage ./packages/quickshell { };
        material-color-utilities = pkgs.callPackage ./packages/material-color-utilities { };
      };

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          nil
          git
        ];
      };

      # Example configurations
      homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.homeManagerModules.default
          {
            home.username = "user";
            home.homeDirectory = "/home/user";
            home.stateVersion = "24.05";
            
            programs.dots-hyprland = {
              enable = true;
              style = "illogical-impulse";
              components = {
                hyprland = true;
                quickshell = true;
                theming = true;
                ai = true;
              };
            };
          }
        ];
      };
    };
}
```

## Action Items for Phase 2

### Module Development
1. **Create base module structure** - directories and basic files
2. **Implement core options** - comprehensive configuration options
3. **Design component interfaces** - how modules interact
4. **Template system** - for dynamic configuration generation

### Integration Points
1. **Home Manager integration** - user-level configuration
2. **NixOS system integration** - system-level services
3. **Flake structure** - proper input/output management
4. **Package overlay** - custom packages integration

### Validation Strategy
1. **Option validation** - ensure configurations are valid
2. **Dependency checking** - verify all required packages
3. **Template testing** - configuration generation works
4. **Module isolation** - components can be disabled independently

## Expected Outcomes

### Deliverables
1. **Complete module structure** - all files and directories
2. **Comprehensive options** - full configuration interface
3. **Working flake** - installable and testable
4. **Documentation** - module usage and configuration

### Success Criteria
- [ ] Module structure created and organized
- [ ] Core options implemented and documented
- [ ] Home Manager integration working
- [ ] NixOS system integration functional
- [ ] Flake builds and installs successfully
- [ ] Components can be enabled/disabled independently
- [ ] Configuration templates generate correctly
- [ ] Ready for Phase 3 (Core Implementation)
