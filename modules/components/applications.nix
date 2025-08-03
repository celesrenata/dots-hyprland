{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.applications;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.applications = {
    enable = mkEnableOption "Essential applications for dots-hyprland";

    terminal = {
      package = mkOption {
        type = types.enum [ "foot" "kitty" ];
        default = "foot";
        description = "Terminal emulator to use";
      };
    };

    launcher = {
      package = mkOption {
        type = types.enum [ "fuzzel" ];
        default = "fuzzel";
        description = "Application launcher to use";
      };
    };

    fileManager = mkOption {
      type = types.str;
      default = "nautilus";
      description = "File manager to use";
    };

    browser = mkOption {
      type = types.str;
      default = "firefox";
      description = "Web browser to use";
    };
  };

  config = mkIf cfg.enable {
    # Terminal configuration
    programs.foot = mkIf (cfg.terminal.package == "foot") {
      enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          login-shell = true;
          app-id = "foot";
          title = "foot";
          font = "JetBrainsMono Nerd Font:size=11";
        };

        bell = {
          urgent = false;
          notify = false;
          visual = false;
        };

        scrollback = {
          lines = 1000;
          multiplier = 3.0;
        };

        url = {
          launch = "xdg-open \${url}";
          label-letters = "sadfjklewcmpgh";
          osc8-underline = "url-mode";
          protocols = "http, https, ftp, ftps, file";
        };

        cursor = {
          style = "beam";
          blink = false;
          beam-thickness = 1.5;
        };

        mouse = {
          hide-when-typing = false;
          alternate-scroll-mode = true;
        };

        colors = {
          alpha = 0.95;
          # Material You colors - will be overridden by theming system
          background = "1a1b26";
          foreground = "c0caf5";
          
          # Regular colors
          regular0 = "15161e";
          regular1 = "f7768e";
          regular2 = "9ece6a";
          regular3 = "e0af68";
          regular4 = "7aa2f7";
          regular5 = "bb9af7";
          regular6 = "7dcfff";
          regular7 = "a9b1d6";
          
          # Bright colors
          bright0 = "414868";
          bright1 = "f7768e";
          bright2 = "9ece6a";
          bright3 = "e0af68";
          bright4 = "7aa2f7";
          bright5 = "bb9af7";
          bright6 = "7dcfff";
          bright7 = "c0caf5";
        };

        key-bindings = {
          scrollback-up-page = "Shift+Page_Up";
          scrollback-down-page = "Shift+Page_Down";
          clipboard-copy = "Control+Shift+c XF86Copy";
          clipboard-paste = "Control+Shift+v XF86Paste";
          primary-paste = "Shift+Insert";
          search-start = "Control+Shift+r";
          font-increase = "Control+plus Control+equal Control+KP_Add";
          font-decrease = "Control+minus Control+KP_Subtract";
          font-reset = "Control+0 Control+KP_0";
          spawn-terminal = "Control+Shift+n";
          fullscreen = "F11";
          show-urls-launch = "Control+Shift+u";
          unicode-input = "Control+Shift+u";
        };
      };
    };

    # Kitty configuration (alternative terminal)
    programs.kitty = mkIf (cfg.terminal.package == "kitty") {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };
      settings = {
        # Material You inspired colors
        background = "#1a1b26";
        foreground = "#c0caf5";
        selection_background = "#33467c";
        selection_foreground = "#c0caf5";
        
        # Cursor
        cursor = "#c0caf5";
        cursor_text_color = "#1a1b26";
        
        # URL
        url_color = "#73daca";
        url_style = "curly";
        
        # Window
        window_padding_width = 8;
        background_opacity = "0.95";
        dynamic_background_opacity = true;
        
        # Tabs
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        
        # Performance
        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = true;
        
        # Bell
        enable_audio_bell = false;
        visual_bell_duration = "0.0";
        
        # Mouse
        mouse_hide_wait = "3.0";
        copy_on_select = false;
        
        # Scrollback
        scrollback_lines = 2000;
        scrollback_pager_history_size = 0;
        wheel_scroll_multiplier = "5.0";
        
        # Colors (Tokyo Night theme as base)
        color0 = "#15161e";
        color1 = "#f7768e";
        color2 = "#9ece6a";
        color3 = "#e0af68";
        color4 = "#7aa2f7";
        color5 = "#bb9af7";
        color6 = "#7dcfff";
        color7 = "#a9b1d6";
        color8 = "#414868";
        color9 = "#f7768e";
        color10 = "#9ece6a";
        color11 = "#e0af68";
        color12 = "#7aa2f7";
        color13 = "#bb9af7";
        color14 = "#7dcfff";
        color15 = "#c0caf5";
      };
    };

    # Fuzzel launcher configuration
    programs.fuzzel = mkIf (cfg.launcher.package == "fuzzel") {
      enable = true;
      settings = {
        main = {
          terminal = "${cfg.terminal.package}";
          layer = "overlay";
          font = "JetBrainsMono Nerd Font:size=12";
          dpi-aware = "auto";
          icon-theme = "Papirus-Dark";
          fields = "filename,name,generic";
          password-character = "*";
          filter-desktop = true;
          no-exit-on-keyboard-focus-loss = false;
        };

        colors = {
          # Material You inspired colors
          background = "1a1b26dd";
          text = "c0caf5ff";
          match = "bb9af7ff";
          selection = "414868ff";
          selection-text = "c0caf5ff";
          selection-match = "bb9af7ff";
          border = "bb9af7ff";
        };

        border = {
          width = 2;
          radius = 12;
        };

        dmenu = {
          exit-immediately-if-empty = true;
        };

        key-bindings = {
          cancel = "Escape Control+c";
          execute = "Return KP_Enter Control+y";
          execute-or-next = "Tab";
          cursor-left = "Left Control+b";
          cursor-left-word = "Control+Left Mod1+b";
          cursor-right = "Right Control+f";
          cursor-right-word = "Control+Right Mod1+f";
          cursor-home = "Home Control+a";
          cursor-end = "End Control+e";
          delete-prev = "BackSpace";
          delete-prev-word = "Mod1+BackSpace Control+BackSpace";
          delete-next = "Delete";
          delete-next-word = "Mod1+d Control+Delete";
          delete-line = "Control+k";
          clear = "Control+l";
          prev = "Up Control+p";
          prev-page = "Page_Up Control+v";
          next = "Down Control+n";
          next-page = "Page_Down Mod1+v";
          first = "Control+Home";
          last = "Control+End";
        };
      };
    };

    # Essential applications
    home.packages = with pkgs; [
      # File manager
      (if cfg.fileManager == "nautilus" then nautilus else pkgs.${cfg.fileManager})
      
      # Browser
      (if cfg.browser == "firefox" then firefox else pkgs.${cfg.browser})
      
      # Image viewer
      imv
      
      # Archive manager
      file-roller
      
      # Text editor
      gedit
      
      # PDF viewer
      evince
      
      # Media player
      mpv
      
      # System monitor
      htop
      
      # Network tools
      networkmanagerapplet
      
      # Audio control
      pavucontrol
      
      # Bluetooth
      blueman
      
      # Screenshot tools
      grim
      slurp
      
      # Color picker
      hyprpicker
      
      # Clipboard manager
      cliphist
      
      # Notification daemon
      libnotify
      
      # XDG utilities
      xdg-utils
      xdg-user-dirs
    ];

    # XDG MIME associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = "gedit.desktop";
        "application/pdf" = "evince.desktop";
        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "inode/directory" = "${cfg.fileManager}.desktop";
        "text/html" = "${cfg.browser}.desktop";
        "x-scheme-handler/http" = "${cfg.browser}.desktop";
        "x-scheme-handler/https" = "${cfg.browser}.desktop";
        "x-scheme-handler/about" = "${cfg.browser}.desktop";
        "x-scheme-handler/unknown" = "${cfg.browser}.desktop";
      };
    };

    # Desktop entries for dots-hyprland specific tools
    xdg.desktopEntries = {
      dots-hyprland-settings = {
        name = "dots-hyprland Settings";
        comment = "Configure dots-hyprland desktop environment";
        exec = "quickshell -c settings";
        icon = "preferences-system";
        categories = [ "Settings" "System" ];
        terminal = false;
      };

      dots-hyprland-overview = {
        name = "Overview";
        comment = "Show desktop overview";
        exec = "quickshell -c overview";
        icon = "view-grid-symbolic";
        categories = [ "Utility" ];
        terminal = false;
        noDisplay = true;
      };
    };
  };
}
