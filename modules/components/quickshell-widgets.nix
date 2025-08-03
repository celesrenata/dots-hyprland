{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.quickshell;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.quickshell = {
    enable = mkEnableOption "Quickshell widget system";

    # Widget modules
    modules = {
      bar = mkEnableOption "Top bar" // { default = true; };
      overview = mkEnableOption "Overview/launcher" // { default = true; };
      background = mkEnableOption "Background widgets";
      cheatsheet = mkEnableOption "Keybind cheatsheet";
      dock = mkEnableOption "Application dock";
      lock = mkEnableOption "Lock screen integration";
      mediaControls = mkEnableOption "Media control widgets";
      notificationPopup = mkEnableOption "Notification popups";
      onScreenDisplay = mkEnableOption "Volume/brightness OSD";
      onScreenKeyboard = mkEnableOption "Virtual keyboard";
      screenCorners = mkEnableOption "Screen corner interactions";
      session = mkEnableOption "Session management widgets";
      sidebarLeft = mkEnableOption "Left sidebar";
      sidebarRight = mkEnableOption "Right sidebar";
    };

    # Configuration options
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

    # Service configuration
    autoStart = mkEnableOption "Auto-start Quickshell with Hyprland" // { default = true; };
    
    restartOnFailure = mkOption {
      type = types.bool;
      default = true;
      description = "Restart Quickshell on failure";
    };
  };

  config = mkIf cfg.enable {
    # Install Quickshell
    home.packages = with pkgs; [
      quickshell
      
      # Dependencies for widgets
      fuzzel          # Launcher backend
      wlogout         # Session management
      translate-shell # For translations
      playerctl       # Media controls
      brightnessctl   # Brightness control
      pamixer         # Audio control
      
      # System tools for widgets
      procps          # System monitoring
      lm_sensors      # Hardware sensors
      networkmanager  # Network info
    ];

    # Copy complete Quickshell configuration
    xdg.configFile = {
      # Main configuration files
      "quickshell/ii/shell.qml".source = ../../configs/quickshell/ii/shell.qml;
      "quickshell/ii/GlobalStates.qml".source = ../../configs/quickshell/ii/GlobalStates.qml;
      "quickshell/ii/ReloadPopup.qml".source = ../../configs/quickshell/ii/ReloadPopup.qml;
      "quickshell/ii/Translation.qml".source = ../../configs/quickshell/ii/Translation.qml;
      "quickshell/ii/screenshot.qml".source = ../../configs/quickshell/ii/screenshot.qml;
      "quickshell/ii/settings.qml".source = ../../configs/quickshell/ii/settings.qml;
      "quickshell/ii/welcome.qml".source = ../../configs/quickshell/ii/welcome.qml;
      
      # Complete modules directory
      "quickshell/ii/modules" = {
        source = ../../configs/quickshell/ii/modules;
        recursive = true;
      };
      
      # Complete services directory
      "quickshell/ii/services" = {
        source = ../../configs/quickshell/ii/services;
        recursive = true;
      };
      
      # Scripts directory
      "quickshell/ii/scripts" = {
        source = ../../configs/quickshell/ii/scripts;
        recursive = true;
      };
      
      # Assets directory
      "quickshell/ii/assets" = {
        source = ../../configs/quickshell/ii/assets;
        recursive = true;
      };
      
      # Defaults directory
      "quickshell/ii/defaults" = {
        source = ../../configs/quickshell/ii/defaults;
        recursive = true;
      };
    };

    # Generate module configuration based on enabled modules
    xdg.configFile."quickshell/ii/shell.qml".text = mkForce ''
      //@ pragma UseQApplication
      //@ pragma Env QS_NO_RELOAD_POPUP=1
      //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
      //@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
      //@ pragma Env QT_SCALE_FACTOR=${toString cfg.scaling}

      import "./modules/common/"
      ${optionalString cfg.modules.background ''import "./modules/background/"''}
      ${optionalString cfg.modules.bar ''import "./modules/bar/"''}
      ${optionalString cfg.modules.cheatsheet ''import "./modules/cheatsheet/"''}
      ${optionalString cfg.modules.dock ''import "./modules/dock/"''}
      ${optionalString cfg.modules.lock ''import "./modules/lock/"''}
      ${optionalString cfg.modules.mediaControls ''import "./modules/mediaControls/"''}
      ${optionalString cfg.modules.notificationPopup ''import "./modules/notificationPopup/"''}
      ${optionalString cfg.modules.onScreenDisplay ''import "./modules/onScreenDisplay/"''}
      ${optionalString cfg.modules.onScreenKeyboard ''import "./modules/onScreenKeyboard/"''}
      ${optionalString cfg.modules.overview ''import "./modules/overview/"''}
      ${optionalString cfg.modules.screenCorners ''import "./modules/screenCorners/"''}
      ${optionalString cfg.modules.session ''import "./modules/session/"''}
      ${optionalString cfg.modules.sidebarLeft ''import "./modules/sidebarLeft/"''}
      ${optionalString cfg.modules.sidebarRight ''import "./modules/sidebarRight/"''}
      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts
      import QtQuick.Window
      import Quickshell
      import "./services/"

      ShellRoot {
          // Enable/disable modules based on configuration
          property bool enableBar: ${boolToString cfg.modules.bar}
          property bool enableBackground: ${boolToString cfg.modules.background}
          property bool enableCheatsheet: ${boolToString cfg.modules.cheatsheet}
          property bool enableDock: ${boolToString cfg.modules.dock}
          property bool enableLock: ${boolToString cfg.modules.lock}
          property bool enableMediaControls: ${boolToString cfg.modules.mediaControls}
          property bool enableNotificationPopup: ${boolToString cfg.modules.notificationPopup}
          property bool enableOnScreenDisplayBrightness: ${boolToString cfg.modules.onScreenDisplay}
          property bool enableOnScreenDisplayVolume: ${boolToString cfg.modules.onScreenDisplay}
          property bool enableOnScreenKeyboard: ${boolToString cfg.modules.onScreenKeyboard}
          property bool enableOverview: ${boolToString cfg.modules.overview}
          property bool enableReloadPopup: true
          property bool enableScreenCorners: ${boolToString cfg.modules.screenCorners}
          property bool enableSession: ${boolToString cfg.modules.session}
          property bool enableSidebarLeft: ${boolToString cfg.modules.sidebarLeft}
          property bool enableSidebarRight: ${boolToString cfg.modules.sidebarRight}

          // Force initialization of singletons
          Component.onCompleted: {
              ${optionalString mainCfg.components.theming ''
              // Material theme integration
              if (typeof MaterialThemeLoader !== 'undefined') {
                  MaterialThemeLoader.reapplyTheme()
              }
              ''}
              
              // Initialize clipboard history
              if (typeof Cliphist !== 'undefined') {
                  Cliphist.refresh()
              }
              
              // Initialize first run experience
              if (typeof FirstRunExperience !== 'undefined') {
                  FirstRunExperience.load()
              }
              
              console.log("dots-hyprland Quickshell initialized")
          }

          // Load enabled modules
          ${optionalString cfg.modules.bar ''LazyLoader { active: enableBar; component: Bar {} }''}
          ${optionalString cfg.modules.background ''LazyLoader { active: enableBackground; component: Background {} }''}
          ${optionalString cfg.modules.cheatsheet ''LazyLoader { active: enableCheatsheet; component: Cheatsheet {} }''}
          ${optionalString cfg.modules.dock ''LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }''}
          ${optionalString cfg.modules.lock ''LazyLoader { active: enableLock; component: Lock {} }''}
          ${optionalString cfg.modules.mediaControls ''LazyLoader { active: enableMediaControls; component: MediaControls {} }''}
          ${optionalString cfg.modules.notificationPopup ''LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }''}
          ${optionalString cfg.modules.onScreenDisplay ''
          LazyLoader { active: enableOnScreenDisplayBrightness; component: OnScreenDisplayBrightness {} }
          LazyLoader { active: enableOnScreenDisplayVolume; component: OnScreenDisplayVolume {} }
          ''}
          ${optionalString cfg.modules.onScreenKeyboard ''LazyLoader { active: enableOnScreenKeyboard; component: OnScreenKeyboard {} }''}
          ${optionalString cfg.modules.overview ''LazyLoader { active: enableOverview; component: Overview {} }''}
          LazyLoader { active: enableReloadPopup; component: ReloadPopup {} }
          ${optionalString cfg.modules.screenCorners ''LazyLoader { active: enableScreenCorners; component: ScreenCorners {} }''}
          ${optionalString cfg.modules.session ''LazyLoader { active: enableSession; component: Session {} }''}
          ${optionalString cfg.modules.sidebarLeft ''LazyLoader { active: enableSidebarLeft; component: SidebarLeft {} }''}
          ${optionalString cfg.modules.sidebarRight ''LazyLoader { active: enableSidebarRight; component: SidebarRight {} }''}
      }
    '';

    # Systemd service for Quickshell
    systemd.user.services.quickshell = mkIf cfg.autoStart {
      Unit = {
        Description = "Quickshell - QtQuick based desktop shell";
        Documentation = [ "https://quickshell.outfoxxed.me/" ];
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
        Requisite = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/qs -c ii";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = if cfg.restartOnFailure then "on-failure" else "no";
        RestartSec = 1;
        TimeoutStopSec = 10;
        
        # Environment variables
        Environment = [
          "QT_SCALE_FACTOR=${toString cfg.scaling}"
          "QT_QUICK_CONTROLS_STYLE=Basic"
          "QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000"
          "QS_NO_RELOAD_POPUP=1"
        ];
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Session variables
    home.sessionVariables = {
      QT_SCALE_FACTOR = toString cfg.scaling;
      QS_CONFIG_PATH = "${config.xdg.configHome}/quickshell";
    };

    # Shell aliases for Quickshell management
    programs.bash.shellAliases = mkIf config.programs.bash.enable {
      "qs-reload" = "systemctl --user reload-or-restart quickshell.service";
      "qs-restart" = "systemctl --user restart quickshell.service";
      "qs-stop" = "systemctl --user stop quickshell.service";
      "qs-start" = "systemctl --user start quickshell.service";
      "qs-status" = "systemctl --user status quickshell.service";
      "qs-logs" = "journalctl --user -u quickshell.service -f";
    };

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
      "qs-reload" = "systemctl --user reload-or-restart quickshell.service";
      "qs-restart" = "systemctl --user restart quickshell.service";
      "qs-stop" = "systemctl --user stop quickshell.service";
      "qs-start" = "systemctl --user start quickshell.service";
      "qs-status" = "systemctl --user status quickshell.service";
      "qs-logs" = "journalctl --user -u quickshell.service -f";
    };

    programs.fish.shellAliases = mkIf config.programs.fish.enable {
      "qs-reload" = "systemctl --user reload-or-restart quickshell.service";
      "qs-restart" = "systemctl --user restart quickshell.service";
      "qs-stop" = "systemctl --user stop quickshell.service";
      "qs-start" = "systemctl --user start quickshell.service";
      "qs-status" = "systemctl --user status quickshell.service";
      "qs-logs" = "journalctl --user -u quickshell.service -f";
    };
  };
}
