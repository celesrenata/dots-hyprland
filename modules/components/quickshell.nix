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

    # Use the original working shell.qml directly instead of generating our own
    home.file.".configstaging/quickshell/shell.qml".source = ../../configs/quickshell/ii/shell.qml;

    # Stage other configuration files in ~/.configstaging/quickshell/
    home.file.".configstaging/quickshell/GlobalStates.qml".source = ../../configs/quickshell/ii/GlobalStates.qml;
    home.file.".configstaging/quickshell/ReloadPopup.qml".source = ../../configs/quickshell/ii/ReloadPopup.qml;
    home.file.".configstaging/quickshell/Translation.qml".source = ../../configs/quickshell/ii/Translation.qml;
    home.file.".configstaging/quickshell/screenshot.qml".source = ../../configs/quickshell/ii/screenshot.qml;
    home.file.".configstaging/quickshell/settings.qml".source = ../../configs/quickshell/ii/settings.qml;
    home.file.".configstaging/quickshell/welcome.qml".source = ../../configs/quickshell/ii/welcome.qml;
    
    # Complete modules directory
    home.file.".configstaging/quickshell/modules" = {
      source = ../../configs/quickshell/ii/modules;
      recursive = true;
    };
    
    # Complete services directory
    home.file.".configstaging/quickshell/services" = {
      source = ../../configs/quickshell/ii/services;
      recursive = true;
    };
    
    # Scripts directory
    home.file.".configstaging/quickshell/scripts" = {
      source = ../../configs/quickshell/ii/scripts;
      recursive = true;
    };
    
    # Assets directory
    home.file.".configstaging/quickshell/assets" = {
      source = ../../configs/quickshell/ii/assets;
      recursive = true;
    };
    
    # Defaults directory
    home.file.".configstaging/quickshell/defaults" = {
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
        ExecStart = "${pkgs.quickshell}/bin/quickshell -c ${config.xdg.configHome}/quickshell/ii";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
        Environment = [
          "QT_SCALE_FACTOR=${toString cfg.scaling}"
          "QT_QUICK_CONTROLS_STYLE=Basic"
          "QML2_IMPORT_PATH=${config.xdg.configHome}/quickshell/ii:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.qt6.qt5compat}/lib/qt-6/qml"
          "PATH=${lib.makeBinPath (with pkgs; [ coreutils findutils gnused gnugrep gawk curl wget jq playerctl htop ])}"
          "XDG_CONFIG_HOME=${config.xdg.configHome}"
          "XDG_DATA_HOME=${config.xdg.dataHome}"
          "XDG_CACHE_HOME=${config.xdg.cacheHome}"
        ];
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Activation script to rsync from staging to actual config directory
    home.activation.quickshellSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Create quickshell config directory
      mkdir -p ~/.config/quickshell
      
      # Rsync from staging to actual config directory
      if [ -d ~/.configstaging/quickshell ]; then
        ${pkgs.rsync}/bin/rsync -azL --no-perms ~/.configstaging/quickshell/ ~/.config/quickshell/ 2>/dev/null || true
        echo "Quickshell configuration synced from staging"
      fi
    '';
  };
}
