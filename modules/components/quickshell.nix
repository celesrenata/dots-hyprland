{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.quickshell;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.quickshell = {
    enable = mkEnableOption "Quickshell widget system";

    autoStart = mkEnableOption "Auto-start Quickshell with Hyprland" // { default = true; };

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
  };

  config = mkIf cfg.enable {
    # Ensure quickshell package is available
    home.packages = with pkgs; [
      quickshell
      fuzzel  # launcher backend
      wlogout # session management
      translate-shell # for translations
    ];

    # Generate shell.qml with file:// URLs to avoid import path issues
    home.file.".config/quickshell/shell.qml".text = ''
      //@ pragma UseQApplication
      //@ pragma Env QS_NO_RELOAD_POPUP=1
      //@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
      //@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

      // Adjust this to make the shell smaller or larger
      //@ pragma Env QT_SCALE_FACTOR=${toString cfg.scaling}

      import "file://${config.home.homeDirectory}/.config/quickshell/modules/common/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/background/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/bar/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/cheatsheet/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/dock/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/lock/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/mediaControls/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/notificationPopup/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/onScreenDisplay/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/onScreenKeyboard/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/overview/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/screenCorners/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/session/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/sidebarLeft/"
      import "file://${config.home.homeDirectory}/.config/quickshell/modules/sidebarRight/"

      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts
      import QtQuick.Window
      import Quickshell
      import "file://${config.home.homeDirectory}/.config/quickshell/services/"

      ShellRoot {
          // Module enable flags
          property bool enableBar: ${lib.boolToString cfg.modules.bar}
          property bool enableOverview: ${lib.boolToString cfg.modules.overview}
          property bool enableSidebarLeft: ${lib.boolToString cfg.modules.sidebarLeft}
          property bool enableSidebarRight: ${lib.boolToString cfg.modules.sidebarRight}
          property bool enableNotificationPopup: ${lib.boolToString cfg.modules.notifications}
          property bool enableMediaControls: ${lib.boolToString cfg.modules.mediaControls}
          property bool enableOnScreenDisplayBrightness: ${lib.boolToString cfg.modules.onScreenDisplay}
          property bool enableOnScreenDisplayVolume: ${lib.boolToString cfg.modules.onScreenDisplay}
          property bool enableCheatsheet: ${lib.boolToString cfg.modules.cheatsheet}
          property bool enableDock: ${lib.boolToString cfg.modules.dock}
          property bool enableScreenCorners: ${lib.boolToString cfg.modules.screenCorners}
          property bool enableOnScreenKeyboard: ${lib.boolToString cfg.modules.onScreenKeyboard}
          property bool enableSession: ${lib.boolToString cfg.modules.session}
          property bool enableLock: ${lib.boolToString cfg.modules.lock}

          // Configuration properties
          property real scaling: ${toString cfg.scaling}
          property string language: "${cfg.language}"

          // Custom configuration
          ${cfg.customConfig}
      }
    '';

    # Copy other configuration files (not shell.qml since we generate it above)
    home.file.".config/quickshell/GlobalStates.qml".source = ../../configs/quickshell/ii/GlobalStates.qml;
    home.file.".config/quickshell/ReloadPopup.qml".source = ../../configs/quickshell/ii/ReloadPopup.qml;
    home.file.".config/quickshell/Translation.qml".source = ../../configs/quickshell/ii/Translation.qml;
    home.file.".config/quickshell/screenshot.qml".source = ../../configs/quickshell/ii/screenshot.qml;
    home.file.".config/quickshell/settings.qml".source = ../../configs/quickshell/ii/settings.qml;
    home.file.".config/quickshell/welcome.qml".source = ../../configs/quickshell/ii/welcome.qml;
    
    # Complete modules directory
    home.file.".config/quickshell/modules" = {
      source = ../../configs/quickshell/ii/modules;
      recursive = true;
    };
    
    # Complete services directory
    home.file.".config/quickshell/services" = {
      source = ../../configs/quickshell/ii/services;
      recursive = true;
    };
    
    # Scripts directory
    home.file.".config/quickshell/scripts" = {
      source = ../../configs/quickshell/ii/scripts;
      recursive = true;
    };
    
    # Assets directory
    home.file.".config/quickshell/assets" = {
      source = ../../configs/quickshell/ii/assets;
      recursive = true;
    };
    
    # Defaults directory
    home.file.".config/quickshell/defaults" = {
      source = ../../configs/quickshell/ii/defaults;
      recursive = true;
    };

    # Systemd service for Quickshell
    systemd.user.services.quickshell = mkIf cfg.autoStart {
      Unit = {
        Description = "Quickshell - QtQuick based desktop shell";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
        Requisite = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/quickshell";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Environment = [
          "QT_SCALE_FACTOR=${toString cfg.scaling}"
          "QT_QUICK_CONTROLS_STYLE=Basic"
        ];
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
