{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.services;
  mainCfg = config.programs.dots-hyprland;
  
  # Service creation utilities
  createUserService = { name, description, execStart, dependencies ? [], environment ? {}, restart ? "on-failure", serviceType ? "simple" }:
    {
      Unit = {
        Description = description;
        After = dependencies;
        Wants = dependencies;
        PartOf = [ "hyprland-session.target" ];
      };

      Service = {
        Type = serviceType;
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
        PartOf = [ "hyprland-session.target" ];
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

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Session environment variables";
      };

      preStartCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run before starting the session";
      };

      postStartCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run after starting the session";
      };
    };

    # Core services configuration
    core = {
      quickshell = {
        enable = mkEnableOption "Quickshell service" // { default = true; };
        restartOnFailure = mkEnableOption "Restart Quickshell on failure" // { default = true; };
        environment = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Environment variables for Quickshell";
        };
        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Extra arguments for Quickshell";
        };
      };

      hypridle = {
        enable = mkEnableOption "Hypridle service" // { default = true; };
        timeout = mkOption {
          type = types.int;
          default = 300;
          description = "Idle timeout in seconds";
        };
        lockCommand = mkOption {
          type = types.str;
          default = "hyprlock";
          description = "Command to run when locking";
        };
      };

      hyprpaper = {
        enable = mkEnableOption "Hyprpaper wallpaper service";
        wallpaper = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Default wallpaper path";
        };
      };
    };

    # Optional services
    optional = {
      polkitAgent = {
        enable = mkEnableOption "PolicyKit authentication agent" // { default = true; };
        package = mkOption {
          type = types.package;
          default = pkgs.polkit-kde-agent;
          description = "PolicyKit agent package to use";
        };
      };

      networkManagerApplet = {
        enable = mkEnableOption "NetworkManager applet";
        indicator = mkEnableOption "Show indicator in system tray" // { default = true; };
      };

      bluetoothApplet = {
        enable = mkEnableOption "Bluetooth applet";
        autoConnect = mkEnableOption "Auto-connect to known devices" // { default = true; };
      };

      clipboardManager = {
        enable = mkEnableOption "Clipboard manager" // { default = true; };
        package = mkOption {
          type = types.package;
          default = pkgs.cliphist;
          description = "Clipboard manager package";
        };
        maxItems = mkOption {
          type = types.int;
          default = 1000;
          description = "Maximum number of clipboard items to store";
        };
      };

      notificationDaemon = {
        enable = mkEnableOption "Notification daemon" // { default = true; };
        package = mkOption {
          type = types.package;
          default = pkgs.libnotify;
          description = "Notification daemon package";
        };
      };
    };

    # Custom services
    custom = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          description = mkOption {
            type = types.str;
            description = "Service description";
          };
          
          execStart = mkOption {
            type = types.str;
            description = "Command to start the service";
          };
          
          execStop = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Command to stop the service";
          };
          
          dependencies = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Service dependencies";
          };
          
          environment = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Environment variables";
          };
          
          restart = mkOption {
            type = types.enum [ "no" "on-success" "on-failure" "on-abnormal" "on-watchdog" "on-abort" "always" ];
            default = "on-failure";
            description = "Restart policy";
          };
          
          serviceType = mkOption {
            type = types.enum [ "simple" "exec" "forking" "oneshot" "dbus" "notify" "idle" ];
            default = "simple";
            description = "Service type";
          };
          
          wantedBy = mkOption {
            type = types.listOf types.str;
            default = [ "hyprland-session.target" ];
            description = "Units that should start this service";
          };
        };
      });
      default = {};
      description = "Custom user services";
    };

    # Service monitoring
    monitoring = {
      enable = mkEnableOption "Service monitoring and health checks";
      
      healthChecks = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            command = mkOption {
              type = types.str;
              description = "Health check command";
            };
            
            interval = mkOption {
              type = types.int;
              default = 30;
              description = "Health check interval in seconds";
            };
            
            timeout = mkOption {
              type = types.int;
              default = 10;
              description = "Health check timeout in seconds";
            };
            
            onFailure = mkOption {
              type = types.str;
              default = "restart";
              description = "Action to take on health check failure";
            };
          };
        });
        default = {};
        description = "Health check configurations";
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

    # All systemd user services combined
    systemd.user.services = {
      # Session environment setup
      "${cfg.session.target}-env" = {
        Unit = {
          Description = "Set up dots-hyprland session environment";
          Before = [ cfg.session.target ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "setup-session-env" ''
            # Set up session environment
            ${lib.concatMapStringsSep "\n" (name: 
              "export ${name}='${cfg.session.environment.${name}}'"
            ) (lib.attrNames cfg.session.environment)}
            
            # Create necessary directories
            mkdir -p "${mainCfg.cacheDir}"
            mkdir -p "${mainCfg.dataDir}"
            
            # Run pre-start commands
            ${cfg.session.preStartCommands}
            
            # Run pre-start hooks
            if [[ -x "${mainCfg.dataDir}/hooks/pre-start.sh" ]]; then
              "${mainCfg.dataDir}/hooks/pre-start.sh"
            fi
          '';
          RemainAfterExit = true;
        };

        Install = {
          WantedBy = [ cfg.session.target ];
        };
      };

      # Post-start service
      "${cfg.session.target}-post" = mkIf (cfg.session.postStartCommands != "") {
        Unit = {
          Description = "Post-start commands for dots-hyprland session";
          After = [ cfg.session.target ];
          Wants = [ cfg.session.target ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "post-start-commands" ''
            # Wait for session to be ready
            sleep 2
            
            # Run post-start commands
            ${cfg.session.postStartCommands}
            
            # Run post-start hooks
            if [[ -x "${mainCfg.dataDir}/hooks/post-start.sh" ]]; then
              "${mainCfg.dataDir}/hooks/post-start.sh"
            fi
          '';
          RemainAfterExit = true;
        };

        Install = {
          WantedBy = [ cfg.session.target ];
        };
      };

      # Core services
      quickshell = mkIf cfg.core.quickshell.enable (
        createUserService {
          name = "quickshell";
          description = "Quickshell - QtQuick based desktop shell";
          execStart = "${pkgs.quickshell}/bin/quickshell ${lib.concatStringsSep " " cfg.core.quickshell.extraArgs}";
          dependencies = [ "${cfg.session.target}-env.service" ];
          environment = cfg.core.quickshell.environment;
          restart = if cfg.core.quickshell.restartOnFailure then "on-failure" else "no";
        }
      );

      hypridle = mkIf cfg.core.hypridle.enable (
        createUserService {
          name = "hypridle";
          description = "Hyprland idle daemon";
          execStart = "${pkgs.hypridle}/bin/hypridle";
          dependencies = [ "hyprland-session.target" ];
          environment = {
            HYPRIDLE_TIMEOUT = toString cfg.core.hypridle.timeout;
            HYPRIDLE_LOCK_CMD = cfg.core.hypridle.lockCommand;
          };
        }
      );

      hyprpaper = mkIf cfg.core.hyprpaper.enable (
        createUserService {
          name = "hyprpaper";
          description = "Hyprland wallpaper daemon";
          execStart = "${pkgs.hyprpaper}/bin/hyprpaper";
          dependencies = [ "hyprland-session.target" ];
        }
      );

      # Optional services
      polkit-agent = mkIf cfg.optional.polkitAgent.enable (
        createUserService {
          name = "polkit-agent";
          description = "PolicyKit authentication agent";
          execStart = "${cfg.optional.polkitAgent.package}/libexec/polkit-kde-authentication-agent-1";
          dependencies = [ "hyprland-session.target" ];
        }
      );

      nm-applet = mkIf cfg.optional.networkManagerApplet.enable (
        createUserService {
          name = "nm-applet";
          description = "NetworkManager applet";
          execStart = "${pkgs.networkmanagerapplet}/bin/nm-applet ${if cfg.optional.networkManagerApplet.indicator then "--indicator" else ""}";
          dependencies = [ "hyprland-session.target" ];
        }
      );

      blueman-applet = mkIf cfg.optional.bluetoothApplet.enable (
        createUserService {
          name = "blueman-applet";
          description = "Bluetooth applet";
          execStart = "${pkgs.blueman}/bin/blueman-applet";
          dependencies = [ "hyprland-session.target" ];
        }
      );

      cliphist = mkIf cfg.optional.clipboardManager.enable (
        createUserService {
          name = "cliphist";
          description = "Clipboard manager";
          execStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${cfg.optional.clipboardManager.package}/bin/cliphist store";
          dependencies = [ "hyprland-session.target" ];
          environment = {
            CLIPHIST_MAX_ITEMS = toString cfg.optional.clipboardManager.maxItems;
          };
        }
      );

      # Service monitoring
      dots-hyprland-monitor = mkIf cfg.monitoring.enable {
        Unit = {
          Description = "dots-hyprland service monitor";
          After = [ cfg.session.target ];
        };

        Service = {
          Type = "simple";
          ExecStart = pkgs.writeShellScript "service-monitor" ''
            #!/usr/bin/env bash
            
            # Service monitoring script
            while true; do
              ${lib.concatMapStringsSep "\n" (name: 
                let check = cfg.monitoring.healthChecks.${name}; in
                ''
                  # Health check for ${name}
                  if timeout ${toString check.timeout} ${check.command} >/dev/null 2>&1; then
                    echo "✅ ${name} health check passed"
                  else
                    echo "❌ ${name} health check failed"
                    
                    case "${check.onFailure}" in
                      restart)
                        echo "Restarting ${name}..."
                        systemctl --user restart ${name}.service || true
                        ;;
                      notify)
                        ${pkgs.libnotify}/bin/notify-send "Service Health Check Failed" \
                          "${name} health check failed" \
                          --icon="dialog-error" || true
                        ;;
                    esac
                  fi
                ''
              ) (lib.attrNames cfg.monitoring.healthChecks)}
              
              sleep 30
            done
          '';
          Restart = "always";
          RestartSec = 10;
        };

        Install = {
          WantedBy = [ cfg.session.target ];
        };
      };
    } // 
    # Custom services
    (lib.mapAttrs' (name: service:
      lib.nameValuePair "dots-hyprland-${name}" {
        Unit = {
          Description = service.description;
          After = service.dependencies;
          Wants = service.dependencies;
        };

        Service = {
          Type = service.serviceType;
          ExecStart = service.execStart;
          ExecStop = mkIf (service.execStop != null) service.execStop;
          Restart = service.restart;
          RestartSec = 1;
          Environment = lib.mapAttrsToList (n: v: "${n}=${v}") service.environment;
        };

        Install = {
          WantedBy = service.wantedBy;
        };
      }
    ) cfg.custom) //
    # Auto-start configured services
    (lib.genAttrs cfg.session.autoStart (serviceName: {
      Install = {
        WantedBy = [ cfg.session.target ];
      };
    }));

    # Service management scripts
    home.file."${mainCfg.dataDir}/bin/service-manager" = {
      text = ''
        #!/usr/bin/env bash
        
        # dots-hyprland service manager
        
        show_help() {
            echo "dots-hyprland service manager"
            echo
            echo "Usage: service-manager [command] [service]"
            echo
            echo "Commands:"
            echo "  status [service]    Show service status"
            echo "  start [service]     Start service"
            echo "  stop [service]      Stop service"
            echo "  restart [service]   Restart service"
            echo "  enable [service]    Enable service"
            echo "  disable [service]   Disable service"
            echo "  logs [service]      Show service logs"
            echo "  list               List all services"
            echo "  health             Run health checks"
            echo "  help               Show this help"
        }
        
        list_services() {
            echo "dots-hyprland services:"
            systemctl --user list-units --type=service | grep -E "(quickshell|hypridle|dots-hyprland)" || echo "No services found"
        }
        
        service_status() {
            local service="$1"
            if [[ -z "$service" ]]; then
                list_services
                return
            fi
            
            systemctl --user status "$service"
        }
        
        service_start() {
            local service="$1"
            if [[ -z "$service" ]]; then
                echo "Please specify a service name"
                return 1
            fi
            
            systemctl --user start "$service"
            echo "Started $service"
        }
        
        service_stop() {
            local service="$1"
            if [[ -z "$service" ]]; then
                echo "Please specify a service name"
                return 1
            fi
            
            systemctl --user stop "$service"
            echo "Stopped $service"
        }
        
        service_restart() {
            local service="$1"
            if [[ -z "$service" ]]; then
                echo "Please specify a service name"
                return 1
            fi
            
            systemctl --user restart "$service"
            echo "Restarted $service"
        }
        
        service_enable() {
            local service="$1"
            if [[ -z "$service" ]]; then
                echo "Please specify a service name"
                return 1
            fi
            
            systemctl --user enable "$service"
            echo "Enabled $service"
        }
        
        service_disable() {
            local service="$1"
            if [[ -z "$service" ]]; then
                echo "Please specify a service name"
                return 1
            fi
            
            systemctl --user disable "$service"
            echo "Disabled $service"
        }
        
        service_logs() {
            local service="$1"
            if [[ -z "$service" ]]; then
                echo "Please specify a service name"
                return 1
            fi
            
            journalctl --user -u "$service" -f
        }
        
        run_health_checks() {
            echo "Running health checks..."
            
            # Check if quickshell is running
            if systemctl --user is-active quickshell >/dev/null 2>&1; then
                echo "✅ Quickshell is running"
            else
                echo "❌ Quickshell is not running"
            fi
            
            # Check if Hyprland is running
            if pgrep -x Hyprland >/dev/null; then
                echo "✅ Hyprland is running"
            else
                echo "❌ Hyprland is not running"
            fi
            
            # Additional health checks would go here
        }
        
        case "''${1:-help}" in
            status) service_status "$2" ;;
            start) service_start "$2" ;;
            stop) service_stop "$2" ;;
            restart) service_restart "$2" ;;
            enable) service_enable "$2" ;;
            disable) service_disable "$2" ;;
            logs) service_logs "$2" ;;
            list) list_services ;;
            health) run_health_checks ;;
            help|*) show_help ;;
        esac
      '';
      executable = true;
    };
  };
}
