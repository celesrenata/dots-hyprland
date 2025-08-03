{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.quickshell;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.quickshell = {
    enable = mkEnableOption "Quickshell widget system";

    # Module configuration - Phase 3 Core Features
    modules = {
      bar = mkEnableOption "Top bar" // { default = true; };
      overview = mkEnableOption "Overview/launcher" // { default = true; };
      sidebarLeft = mkEnableOption "Left sidebar" // { default = true; };
      sidebarRight = mkEnableOption "Right sidebar" // { default = true; };
      notifications = mkEnableOption "Notification popups" // { default = true; };
      mediaControls = mkEnableOption "Media control widgets" // { default = true; };
      onScreenDisplay = mkEnableOption "Volume/brightness OSD" // { default = true; };
      cheatsheet = mkEnableOption "Keybind cheatsheet" // { default = true; };
      
      # Phase 4: Advanced Features
      dock = mkEnableOption "Application dock";
      screenCorners = mkEnableOption "Screen corner interactions";
      onScreenKeyboard = mkEnableOption "Virtual keyboard";
      session = mkEnableOption "Session management widgets";
      lock = mkEnableOption "Lock screen integration";
    };

    # UI configuration
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

    # Custom configuration
    customConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Quickshell configuration";
    };
  };

  config = mkIf cfg.enable {
    # Add quickshell and related packages
    home.packages = with pkgs; [
      quickshell      # main widget system
      fuzzel          # launcher backend
      wlogout         # session management
      translate-shell # for translations
      libnotify       # notifications
      playerctl       # media controls
      brightnessctl   # brightness control
      pamixer         # audio control
    ];

    # Generate main shell.qml configuration
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
          // Module enable flags
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

          // Configuration properties
          property real scalingFactor: ${toString cfg.scaling}
          property string language: "${cfg.language}"
          property string style: "${mainCfg.style}"

          ${cfg.customConfig}
      }
    '';

    # Generate settings.qml configuration
    xdg.configFile."quickshell/ii/settings.qml".text = ''
      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts

      ApplicationWindow {
          id: settingsWindow
          title: "illogical-impulse Settings"
          width: 800
          height: 600
          visible: true

          ScrollView {
              anchors.fill: parent
              
              ColumnLayout {
                  width: parent.width
                  spacing: 20
                  
                  Text {
                      text: "dots-hyprland Configuration"
                      font.pixelSize: 24
                      font.bold: true
                  }
                  
                  GroupBox {
                      title: "Modules"
                      Layout.fillWidth: true
                      
                      GridLayout {
                          columns: 2
                          
                          CheckBox {
                              text: "Top Bar"
                              checked: ${boolToString cfg.modules.bar}
                              enabled: false
                          }
                          
                          CheckBox {
                              text: "Overview"
                              checked: ${boolToString cfg.modules.overview}
                              enabled: false
                          }
                          
                          CheckBox {
                              text: "Sidebars"
                              checked: ${boolToString (cfg.modules.sidebarLeft || cfg.modules.sidebarRight)}
                              enabled: false
                          }
                          
                          CheckBox {
                              text: "Notifications"
                              checked: ${boolToString cfg.modules.notifications}
                              enabled: false
                          }
                      }
                  }
                  
                  GroupBox {
                      title: "Configuration"
                      Layout.fillWidth: true
                      
                      GridLayout {
                          columns: 2
                          
                          Label { text: "Scaling Factor:" }
                          SpinBox {
                              from: 50
                              to: 300
                              value: ${toString (cfg.scaling * 100)}
                              suffix: "%"
                              enabled: false
                          }
                          
                          Label { text: "Language:" }
                          ComboBox {
                              model: ["en_US", "es_ES", "fr_FR", "de_DE"]
                              currentIndex: model.indexOf("${cfg.language}")
                              enabled: false
                          }
                      }
                  }
                  
                  Text {
                      text: "Note: Settings are configured through NixOS configuration."
                      font.italic: true
                      color: "gray"
                  }
              }
          }
      }
    '';

    # Copy Quickshell configuration templates (will be created in next steps)
    xdg.configFile."quickshell/ii/modules" = {
      source = ../../configs/quickshell/ii/modules;
      recursive = true;
    };

    xdg.configFile."quickshell/ii/services" = {
      source = ../../configs/quickshell/ii/services;
      recursive = true;
    };

    # Language configuration
    xdg.configFile."quickshell/translations/${cfg.language}.json" = {
      source = ../../configs/quickshell/translations + "/${cfg.language}.json";
    };

    # Systemd service for Quickshell
    systemd.user.services.quickshell = {
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
          "QUICKSHELL_CONFIG_DIR=${mainCfg.configDir}/quickshell"
        ];
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Create hyprland session target
    systemd.user.targets.hyprland-session = {
      Unit = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
