{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland;
in
{
  # Import core components for Phase 5 testing
  imports = [
    ./components/packages.nix
    ./components/hyprland-config.nix  # Actual Hyprland configuration
    ./components/material-you-theming.nix  # Material You theming system
    ./components/quickshell-widgets.nix  # Complete Quickshell widget system
    ./components/session-management.nix  # NEW: Proper session management
    # ./components/ai.nix  # Temporarily disabled for testing
    # ./components/customization.nix  # Temporarily disabled for testing
  ];

  options.programs.dots-hyprland = {
    enable = mkEnableOption "end-4's dots-hyprland desktop environment";

    style = mkOption {
      type = types.enum [ "illogical-impulse" ];
      default = "illogical-impulse";
      description = "The style variant to use";
    };

    # Component toggles - Phase 3 Priority system
    components = {
      hyprland = mkEnableOption "Hyprland window manager" // { default = true; };
      quickshell = mkEnableOption "Quickshell widget system" // { default = true; };
      theming = mkEnableOption "Material You theming" // { default = false; };
      ai = mkEnableOption "AI integration (Gemini/Ollama)"; # Phase 4
      audio = mkEnableOption "Audio system integration" // { default = true; };
      development = mkEnableOption "Development tools and utilities";
    };

    # Hardware configuration
    hardware = {
      nvidia = mkEnableOption "NVIDIA GPU support";
      amd = mkEnableOption "AMD GPU support";
      intel = mkEnableOption "Intel GPU support" // { default = true; };
    };

    # Feature toggles - Phase 3 Core Features
    features = {
      overview = mkEnableOption "Overview/launcher widget" // { default = true; };
      sidebar = mkEnableOption "Left and right sidebars" // { default = false; };
      notifications = mkEnableOption "Notification system" // { default = true; };
      mediaControls = mkEnableOption "Media control widgets" // { default = true; };
      
      # Phase 4: Advanced Features
      screenCorners = mkEnableOption "Screen corner interactions";
      onScreenKeyboard = mkEnableOption "On-screen keyboard";
      cheatsheet = mkEnableOption "Keybind cheatsheet" // { default = true; };
    };

    # Keybind configuration
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
    };

    # Directory configuration
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
      DOTS_HYPRLAND_STYLE = cfg.style;
    };

    # Enable core components for Phase 5 testing
    programs.dots-hyprland.packages.enable = true;
    programs.dots-hyprland.hyprland.enable = mkIf cfg.components.hyprland true;
    programs.dots-hyprland.quickshell.enable = mkIf cfg.components.quickshell true;
    programs.dots-hyprland.theming.enable = mkIf cfg.components.theming true;
    programs.dots-hyprland.session.enable = mkIf cfg.enable true;  # Session management
    # programs.dots-hyprland.ai.enable = mkIf cfg.components.ai true;  # Temporarily disabled
    # programs.dots-hyprland.customization.enable = mkIf cfg.enable true;  # Temporarily disabled
    
    # Direct Hyprland configuration - avoiding module conflicts
    wayland.windowManager.hyprland = mkIf cfg.components.hyprland {
      enable = true;
      
      # Use extraConfig to avoid Home Manager option conflicts
      extraConfig = ''
        # Variables
        $mod = ${cfg.keybinds.modifier}
        $terminal = ${cfg.keybinds.terminal}
        
        # Monitor configuration
        monitor = ,preferred,auto,1
        
        # General settings - dots-hyprland style
        general {
            gaps_in = 4
            gaps_out = 8
            border_size = 2
            col.active_border = rgba(bb9af7ff)
            col.inactive_border = rgba(414868ff)
            layout = dwindle
        }
        
        # Decoration
        decoration {
            rounding = 12
            drop_shadow = true
            shadow_range = 30
            shadow_render_power = 3
            col.shadow = 0x66000000
        }
        
        # Animations
        animations {
            enabled = true
            bezier = materialEaseInOut,0.4, 0, 0.2, 1
            animation = windows,1,3,materialEaseInOut,slide
            animation = border,1,10,default
            animation = fade,1,2,materialEaseInOut
            animation = workspaces,1,3,materialEaseInOut,slide
        }
        
        # Input
        input {
            kb_layout = us
            follow_mouse = 1
            touchpad {
                natural_scroll = true
            }
        }
        
        # Misc
        misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
        }
        
        # Core keybinds
        bind = $mod, Return, exec, $terminal
        bind = $mod, Q, killactive
        bind = $mod, M, exit
        bind = $mod, E, exec, nautilus
        bind = $mod, V, togglefloating
        bind = $mod, F, fullscreen
        bind = $mod, Space, exec, fuzzel
        
        # Focus movement
        bind = $mod, left, movefocus, l
        bind = $mod, right, movefocus, r
        bind = $mod, up, movefocus, u
        bind = $mod, down, movefocus, d
        bind = $mod, h, movefocus, l
        bind = $mod, l, movefocus, r
        bind = $mod, k, movefocus, u
        bind = $mod, j, movefocus, d
        
        # Workspace switching (1-10)
        bind = $mod, 1, workspace, 1
        bind = $mod, 2, workspace, 2
        bind = $mod, 3, workspace, 3
        bind = $mod, 4, workspace, 4
        bind = $mod, 5, workspace, 5
        bind = $mod, 6, workspace, 6
        bind = $mod, 7, workspace, 7
        bind = $mod, 8, workspace, 8
        bind = $mod, 9, workspace, 9
        bind = $mod, 0, workspace, 10
        
        # Move to workspace
        bind = $mod SHIFT, 1, movetoworkspace, 1
        bind = $mod SHIFT, 2, movetoworkspace, 2
        bind = $mod SHIFT, 3, movetoworkspace, 3
        bind = $mod SHIFT, 4, movetoworkspace, 4
        bind = $mod SHIFT, 5, movetoworkspace, 5
        bind = $mod SHIFT, 6, movetoworkspace, 6
        bind = $mod SHIFT, 7, movetoworkspace, 7
        bind = $mod SHIFT, 8, movetoworkspace, 8
        bind = $mod SHIFT, 9, movetoworkspace, 9
        bind = $mod SHIFT, 0, movetoworkspace, 10
        
        # Mouse binds
        bindm = $mod, mouse:272, movewindow
        bindm = $mod, mouse:273, resizewindow
        
        # Window rules
        windowrule = float,^(pavucontrol)$
        windowrule = float,^(nm-connection-editor)$
        windowrule = float,^(fuzzel)$
        windowrule = opacity 0.9 0.9,^(foot)$
      '';
    };
    
    # Essential applications
    programs.foot = mkIf (cfg.components.hyprland && cfg.keybinds.terminal == "foot") {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          term = "xterm-256color";
        };
        colors = {
          alpha = 0.95;
          background = "1a1b26";
          foreground = "c0caf5";
          
          # Tokyo Night colors
          regular0 = "15161e";
          regular1 = "f7768e";
          regular2 = "9ece6a";
          regular3 = "e0af68";
          regular4 = "7aa2f7";
          regular5 = "bb9af7";
          regular6 = "7dcfff";
          regular7 = "a9b1d6";
          
          bright0 = "414868";
          bright1 = "f7768e";
          bright2 = "9ece6a";
          bright3 = "e0af68";
          bright4 = "7aa2f7";
          bright5 = "bb9af7";
          bright6 = "7dcfff";
          bright7 = "c0caf5";
        };
      };
    };
    
    programs.fuzzel = mkIf cfg.components.hyprland {
      enable = true;
      settings = {
        main = {
          terminal = cfg.keybinds.terminal;
          font = "JetBrainsMono Nerd Font:size=12";
          layer = "overlay";
        };
        colors = {
          background = "1a1b26dd";
          text = "c0caf5ff";
          selection = "414868ff";
          selection-text = "c0caf5ff";
          border = "bb9af7ff";
        };
        border = {
          width = 2;
          radius = 12;
        };
      };
    };

    # Essential packages for desktop environment
    home.packages = with pkgs; mkIf cfg.components.hyprland [
      # File manager
      nautilus
      
      # System utilities
      pavucontrol
      networkmanagerapplet
      
      # Wayland utilities
      wl-clipboard
      grim
      slurp
      
      # XDG
      xdg-utils
      xdg-user-dirs
    ];

    # Assertions for configuration validation
    assertions = [
      {
        assertion = cfg.components.quickshell -> cfg.components.hyprland;
        message = "Quickshell requires Hyprland to be enabled";
      }
    ];
  };
}
