{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.hyprland;
  mainCfg = config.programs.dots-hyprland;
  
  # Template substitution function
  processTemplate = template: substitutions:
    lib.replaceStrings
      (map (name: "@${name}@") (lib.attrNames substitutions))
      (lib.attrValues substitutions)
      template;

  # Application lists for keybinds
  terminalApps = "\"${pkgs.foot}/bin/foot\" \"${pkgs.kitty}/bin/kitty\" \"${pkgs.alacritty}/bin/alacritty\"";
  fileManagerApps = "\"${pkgs.nautilus}/bin/nautilus\" \"${pkgs.kdePackages.dolphin}/bin/dolphin\" \"${pkgs.xfce.thunar}/bin/thunar\"";
  browserApps = "\"${pkgs.firefox}/bin/firefox\" \"${pkgs.chromium}/bin/chromium\"";
  codeEditorApps = "\"${pkgs.vscodium}/bin/codium\" \"${pkgs.kdePackages.kate}/bin/kate\"";
  
  # Template substitutions
  templateVars = {
    # Binaries
    QUICKSHELL_BIN = "${pkgs.quickshell}/bin/qs";
    FUZZEL_BIN = "${pkgs.fuzzel}/bin/fuzzel";
    WLOGOUT_BIN = "${pkgs.wlogout}/bin/wlogout";
    BRIGHTNESSCTL_BIN = "${pkgs.brightnessctl}/bin/brightnessctl";
    WPCTL_BIN = "${pkgs.wireplumber}/bin/wpctl";
    HYPRSHOT_BIN = "${pkgs.hyprshot}/bin/hyprshot";
    GRIM_BIN = "${pkgs.grim}/bin/grim";
    SLURP_BIN = "${pkgs.slurp}/bin/slurp";
    WL_COPY_BIN = "${pkgs.wl-clipboard}/bin/wl-copy";
    HYPRPICKER_BIN = "${pkgs.hyprpicker}/bin/hyprpicker";
    TESSERACT_BIN = "${pkgs.tesseract}/bin/tesseract";
    PLAYERCTL_BIN = "${pkgs.playerctl}/bin/playerctl";
    CLIPHIST_BIN = "${pkgs.cliphist}/bin/cliphist";
    HYPRIDLE_BIN = "${pkgs.hypridle}/bin/hypridle";
    GNOME_KEYRING_BIN = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon";
    POLKIT_AGENT_BIN = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
    
    # Application lists
    TERMINAL_APPS = terminalApps;
    FILE_MANAGER_APPS = fileManagerApps;
    BROWSER_APPS = browserApps;
    CODE_EDITOR_APPS = codeEditorApps;
    OFFICE_APPS = "\"libreoffice\"";
    TEXT_EDITOR_APPS = "\"${pkgs.kdePackages.kate}/bin/kate\" \"${pkgs.gedit}/bin/gedit\"";
    VOLUME_MIXER_APPS = "\"${pkgs.pavucontrol}/bin/pavucontrol\"";
    SETTINGS_APPS = "\"${pkgs.gnome-control-center}/bin/gnome-control-center\"";
    TASK_MANAGER_APPS = "\"${pkgs.gnome-system-monitor}/bin/gnome-system-monitor\"";
    
    # Configuration values
    MONITOR_CONFIG = concatMapStringsSep "\n" (m: 
      "monitor=${m.name},${m.resolution}@${toString m.refreshRate},${m.position},${toString m.scale}"
    ) cfg.monitors;
    
    WORKSPACE_SWIPE = if cfg.gestures.workspaceSwipe then "true" else "false";
    GAPS_IN = toString cfg.appearance.gaps.inner;
    GAPS_OUT = toString cfg.appearance.gaps.outer;
    BORDER_SIZE = toString cfg.appearance.border.size;
    ROUNDING = toString cfg.appearance.rounding;
    BLUR_ENABLED = if cfg.appearance.blur.enable then "true" else "false";
    BLUR_SIZE = toString cfg.appearance.blur.size;
    BLUR_PASSES = toString cfg.appearance.blur.passes;
    SHADOW_ENABLED = if cfg.appearance.shadow.enable then "true" else "false";
    ANIMATIONS_ENABLED = if cfg.animations.enable then "true" else "false";
    DIM_INACTIVE = if cfg.appearance.dimInactive then "true" else "false";
    ALLOW_TEARING = if cfg.performance.allowTearing then "true" else "false";
    VRR_ENABLED = if cfg.performance.vrr then "1" else "0";
    WINDOW_SWALLOW = if cfg.behavior.windowSwallow then "true" else "false";
    NATURAL_SCROLL = if cfg.input.touchpad.naturalScroll then "yes" else "no";
    KEYBOARD_LAYOUT = cfg.input.keyboard.layout;
    
    # Colors (will be populated by theming system)
    ACTIVE_BORDER_COLOR = "rgba(0DB7D4FF)";
    INACTIVE_BORDER_COLOR = "rgba(31313600)";
    BACKGROUND_COLOR = "rgba(1D1011FF)";
    SHADOW_COLOR = "rgba(00000010)";
    OVERVIEW_BG_COLOR = "rgb(000000)";
    
    # Environment variables
    QT_THEME = "kde";
    NVIDIA_ENV = if mainCfg.hardware.nvidia then "env = LIBVA_DRIVER_NAME,nvidia\nenv = XDG_SESSION_TYPE,wayland\nenv = GBM_BACKEND,nvidia-drm\nenv = __GLX_VENDOR_LIBRARY_NAME,nvidia" else "";
    AMD_ENV = if mainCfg.hardware.amd then "env = LIBVA_DRIVER_NAME,radeonsi" else "";
    DATA_DIR = mainCfg.dataDir;
    
    # Audio and input method
    AUDIO_EXEC = if mainCfg.components.audio then "exec-once = ${pkgs.easyeffects}/bin/easyeffects --gapplication-service" else "";
    INPUT_METHOD_EXEC = if cfg.inputMethod.enable then "exec-once = ${pkgs.fcitx5}/bin/fcitx5" else "";
    
    # Cursor
    CURSOR_THEME = cfg.cursor.theme;
    CURSOR_SIZE = toString cfg.cursor.size;
    
    # Custom configurations
    CUSTOM_EXECS = cfg.customExecs;
    CUSTOM_KEYBINDS = cfg.customKeybinds;
    CUSTOM_WINDOW_RULES = cfg.customWindowRules;
    GLOBAL_TRANSPARENCY = if cfg.appearance.globalTransparency != null 
      then "windowrulev2 = opacity ${toString cfg.appearance.globalTransparency} override ${toString cfg.appearance.globalTransparency} override, class:.*"
      else "# windowrulev2 = opacity 0.89 override 0.89 override, class:.*";
    
    # Additional colors for theming
    ADDITIONAL_COLORS = "";
    
    # Color template variables
    SLURP_BORDER_COLOR = "FFDAD4BB";
    SLURP_BACKGROUND_COLOR = "673B3444";
    BAR_FONT = "Rubik, Geist, AR One Sans, Reddit Sans, Inter, Roboto, Ubuntu, Noto Sans, sans-serif";
    BAR_HEIGHT = "30";
    BAR_BACKGROUND_COLOR = "rgba(1D1011FF)";
    BAR_TEXT_COLOR = "rgba(F7DCDEFF)";
    BUTTON_COLOR = "rgb(F7DCDE)";
    PINNED_BORDER_COLOR = "rgba(FFB2BCAA)";
    PINNED_BORDER_COLOR_INACTIVE = "rgba(FFB2BC77)";
  };

in
{
  options.programs.dots-hyprland.hyprland = {
    enable = mkEnableOption "Hyprland configuration for dots-hyprland";

    # Monitor configuration
    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor name";
            example = "DP-1";
          };
          resolution = mkOption {
            type = types.str;
            default = "preferred";
            description = "Monitor resolution";
            example = "1920x1080";
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
            example = "1920x0";
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
            description = "Monitor scale factor";
          };
        };
      });
      default = [{ name = ""; resolution = "preferred"; refreshRate = 60; position = "auto"; scale = 1.0; }];
      description = "Monitor configuration";
    };

    # Appearance settings
    appearance = {
      gaps = {
        inner = mkOption {
          type = types.int;
          default = 4;
          description = "Inner gaps between windows";
        };
        outer = mkOption {
          type = types.int;
          default = 5;
          description = "Outer gaps around windows";
        };
      };
      
      border = {
        size = mkOption {
          type = types.int;
          default = 1;
          description = "Border size in pixels";
        };
      };
      
      rounding = mkOption {
        type = types.int;
        default = 18;
        description = "Corner rounding radius";
      };
      
      blur = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable blur effects";
        };
        size = mkOption {
          type = types.int;
          default = 14;
          description = "Blur size";
        };
        passes = mkOption {
          type = types.int;
          default = 3;
          description = "Number of blur passes";
        };
      };
      
      shadow = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable window shadows";
        };
      };
      
      dimInactive = mkOption {
        type = types.bool;
        default = true;
        description = "Dim inactive windows";
      };
      
      globalTransparency = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Global transparency (0.0-1.0)";
        example = 0.89;
      };
    };

    # Animation settings
    animations = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable animations";
      };
    };

    # Gesture settings
    gestures = {
      workspaceSwipe = mkOption {
        type = types.bool;
        default = true;
        description = "Enable workspace swipe gestures";
      };
    };

    # Input settings
    input = {
      keyboard = {
        layout = mkOption {
          type = types.str;
          default = "us";
          description = "Keyboard layout";
        };
      };
      
      touchpad = {
        naturalScroll = mkOption {
          type = types.bool;
          default = true;
          description = "Enable natural scrolling";
        };
      };
    };

    # Performance settings
    performance = {
      allowTearing = mkOption {
        type = types.bool;
        default = true;
        description = "Allow tearing for gaming";
      };
      
      vrr = mkOption {
        type = types.bool;
        default = true;
        description = "Enable variable refresh rate";
      };
    };

    # Behavior settings
    behavior = {
      windowSwallow = mkOption {
        type = types.bool;
        default = false;
        description = "Enable window swallowing";
      };
    };

    # Input method settings
    inputMethod = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable input method (fcitx5)";
      };
    };

    # Cursor settings
    cursor = {
      theme = mkOption {
        type = types.str;
        default = "Bibata-Modern-Classic";
        description = "Cursor theme name";
      };
      
      size = mkOption {
        type = types.int;
        default = 24;
        description = "Cursor size";
      };
    };

    # Custom configurations
    customExecs = mkOption {
      type = types.lines;
      default = "";
      description = "Custom exec-once commands";
    };

    customKeybinds = mkOption {
      type = types.lines;
      default = "";
      description = "Custom keybinds";
    };

    customWindowRules = mkOption {
      type = types.lines;
      default = "";
      description = "Custom window rules";
    };
  };

  config = mkIf cfg.enable {
    # Install essential scripts to ~/.config/hypr/scripts/
    xdg.configFile = {
      "hypr/scripts/fuzzel-emoji.sh" = {
        source = ../../scripts/fuzzel-emoji.sh;
        executable = true;
      };
      "hypr/scripts/record.sh" = {
        source = ../../scripts/record.sh;
        executable = true;
      };
      "hypr/scripts/zoom.sh" = {
        source = ../../scripts/zoom.sh;
        executable = true;
      };
      
      # wlogout session menu configuration
      "wlogout/layout".source = ../../configs/matugen/templates/wlogout/layout;
      
      # hypridle configuration for automatic screen locking
      "hypr/hypridle.conf".source = ../../configs/hypr/hypridle.conf.template;
      
      # Hyprland configuration files
      "hypr/hyprland.conf".text = processTemplate (builtins.readFile ../../configs/hypr/hyprland.conf.template) templateVars;
      "hypr/env.conf".text = processTemplate (builtins.readFile ../../configs/hypr/env.conf.template) templateVars;
      "hypr/execs.conf".text = processTemplate (builtins.readFile ../../configs/hypr/execs.conf.template) templateVars;
      "hypr/general.conf".text = processTemplate (builtins.readFile ../../configs/hypr/general.conf.template) templateVars;
      "hypr/keybinds.conf".text = processTemplate (builtins.readFile ../../configs/hypr/keybinds.conf.template) templateVars;
      "hypr/colors.conf".text = processTemplate (builtins.readFile ../../configs/hypr/colors.conf.template) templateVars;
      "hypr/rules.conf".text = processTemplate (builtins.readFile ../../configs/hypr/rules.conf.template) templateVars;
      
      # Scripts
      "hypr/scripts/launch_first_available.sh" = {
        source = ../../configs/hypr/scripts/launch_first_available.sh;
        executable = true;
      };
      "hypr/scripts/workspace_action.sh" = {
        source = ../../configs/hypr/scripts/workspace_action.sh;
        executable = true;
      };
    };

    # Enable Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      
      # Use our generated configuration
      extraConfig = ''
        # This file is managed by dots-hyprland NixOS module
        # Your configuration is in ~/.config/hypr/hyprland.conf
      '';
    };

    # Required packages for Hyprland functionality
    home.packages = with pkgs; [
      # Core Hyprland ecosystem
      hyprland hypridle hyprlock hyprpicker hyprsunset hyprutils
      hyprwayland-scanner xdg-desktop-portal-hyprland
      
      # Screenshot and screen tools
      grim slurp hyprshot
      
      # Recording tools (for record.sh)
      wf-recorder
      
      # Clipboard and utilities
      wl-clipboard cliphist
      
      # Audio and media
      wireplumber playerctl
      
      # System tools
      brightnessctl tesseract
      
      # Math and utilities (for zoom.sh)
      bc jq
      
      # Notifications
      libnotify
      
      # Authentication
      gnome-keyring kdePackages.polkit-kde-agent-1
      
      # Applications (basic set)
      foot kitty fuzzel wlogout nautilus
    ];

    # Systemd services for Hyprland ecosystem
    systemd.user.services.hypridle = {
      Unit = {
        Description = "Hyprland idle daemon";
        Documentation = [ "man:hypridle(1)" ];
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
