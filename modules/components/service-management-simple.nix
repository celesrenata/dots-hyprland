{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.services;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.services = {
    enable = mkEnableOption "Service management for dots-hyprland" // { default = true; };

    # Session management
    session = {
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
    };

    # Core services configuration
    core = {
      quickshell = {
        enable = mkEnableOption "Quickshell service" // { default = true; };
        restartOnFailure = mkEnableOption "Restart Quickshell on failure" // { default = true; };
      };

      hypridle = {
        enable = mkEnableOption "Hypridle service" // { default = true; };
        timeout = mkOption {
          type = types.int;
          default = 300;
          description = "Idle timeout in seconds";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Create session target
    systemd.user.targets."${cfg.session.target}" = {
      Unit = {
        Description = "dots-hyprland session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    # Core services
    systemd.user.services = {
      quickshell = mkIf cfg.core.quickshell.enable {
        Unit = {
          Description = "Quickshell - QtQuick based desktop shell";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.quickshell}/bin/quickshell";
          Restart = if cfg.core.quickshell.restartOnFailure then "on-failure" else "no";
          RestartSec = 1;
        };

        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
      };

      hypridle = mkIf cfg.core.hypridle.enable {
        Unit = {
          Description = "Hyprland idle daemon";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.hypridle}/bin/hypridle";
          Restart = "on-failure";
          RestartSec = 1;
          Environment = [
            "HYPRIDLE_TIMEOUT=${toString cfg.core.hypridle.timeout}"
          ];
        };

        Install = {
          WantedBy = [ "hyprland-session.target" ];
        };
      };
    };

    # Service management script
    home.file."${mainCfg.dataDir}/bin/service-manager" = {
      text = ''
        #!/usr/bin/env bash
        
        # Simple service manager for dots-hyprland
        
        case "''${1:-help}" in
            status)
                systemctl --user status quickshell hypridle
                ;;
            start)
                systemctl --user start hyprland-session.target
                ;;
            stop)
                systemctl --user stop hyprland-session.target
                ;;
            restart)
                systemctl --user restart hyprland-session.target
                ;;
            logs)
                journalctl --user -u quickshell -u hypridle -f
                ;;
            *)
                echo "Usage: service-manager {status|start|stop|restart|logs}"
                ;;
        esac
      '';
      executable = true;
    };
  };
}
