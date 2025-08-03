{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.session;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.session = {
    enable = mkEnableOption "Session management" // { default = true; };

    target = mkOption {
      type = types.str;
      default = "hyprland-session.target";
      description = "Systemd target for the Hyprland session";
    };

    autoStart = mkOption {
      type = types.listOf types.str;
      default = [ "quickshell" "hypridle" ];
      description = "Services to start automatically with the session";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Session environment variables";
    };
  };

  config = mkIf cfg.enable {
    # Create Hyprland session target
    systemd.user.targets."${cfg.target}" = {
      Unit = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    # Session environment setup service
    systemd.user.services."${cfg.target}-env" = {
      Unit = {
        Description = "Set up Hyprland session environment";
        Before = [ cfg.target ];
        PartOf = [ cfg.target ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-hyprland-session-env" ''
          # Set up session environment variables
          ${lib.concatMapStringsSep "\n" (name: 
            "export ${name}='${cfg.environment.${name}}'"
          ) (lib.attrNames cfg.environment)}
          
          # Create necessary directories
          mkdir -p "${mainCfg.dataDir}"
          mkdir -p "${mainCfg.cacheDir}"
          
          # Set up XDG directories
          ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update
          
          echo "Hyprland session environment ready"
        '';
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = [ cfg.target ];
      };
    };

    # Ensure auto-start services are wanted by the session target
    systemd.user.services = lib.genAttrs cfg.autoStart (serviceName: {
      Install = {
        WantedBy = [ cfg.target ];
      };
    });

    # Session variables
    home.sessionVariables = cfg.environment // {
      HYPRLAND_SESSION_TARGET = cfg.target;
    };
  };
}
