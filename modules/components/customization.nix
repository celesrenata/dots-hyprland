{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.customization;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.customization = {
    enable = mkEnableOption "User customization support" // { default = true; };

    # Custom configuration files
    customConfigs = mkOption {
      type = types.attrsOf (types.either types.path types.str);
      default = {};
      description = "Custom configuration files to override defaults";
      example = {
        "hypr/hyprland.conf" = ./my-hyprland.conf;
        "quickshell/ii/shell.qml" = ''
          // Custom Quickshell configuration
          import "./modules/common/"
          // ... custom content
        '';
      };
    };

    # Custom scripts
    customScripts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          source = mkOption {
            type = types.either types.path types.str;
            description = "Script source (file path or content)";
          };
          executable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether the script should be executable";
          };
          dependencies = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Packages required by this script";
          };
        };
      });
      default = {};
      description = "Custom scripts to add or override";
      example = {
        "color-generator" = {
          source = ./my-color-script.py;
          dependencies = [ pkgs.python3 pkgs.python3Packages.pillow ];
        };
        "startup-hook" = {
          source = ''
            #!/usr/bin/env bash
            echo "Custom startup hook"
            # Custom startup logic here
          '';
        };
      };
    };

    # Environment variables
    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Custom environment variables";
      example = {
        "CUSTOM_THEME_PATH" = "/path/to/themes";
        "AI_MODEL_PREFERENCE" = "llama2";
        "EDITOR" = "nvim";
      };
    };

    # Custom packages
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install";
      example = [ pkgs.firefox pkgs.discord pkgs.spotify ];
    };

    # Hooks system
    hooks = {
      preStart = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run before starting dots-hyprland";
        example = ''
          echo "Starting dots-hyprland..."
          # Custom pre-start logic
        '';
      };

      postStart = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run after starting dots-hyprland";
        example = ''
          echo "dots-hyprland started successfully"
          # Custom post-start logic
        '';
      };

      colorChange = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run when colors change";
        example = ''
          echo "Colors changed, updating custom applications..."
          # Custom color change logic
        '';
      };

      beforeShutdown = mkOption {
        type = types.lines;
        default = "";
        description = "Commands to run before system shutdown";
        example = ''
          echo "Preparing for shutdown..."
          # Custom cleanup logic
        '';
      };
    };

    # Template overrides
    templateOverrides = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Override template variables";
      example = {
        "BACKGROUND_COLOR" = "#1e1e2e";
        "ACCENT_COLOR" = "#cba6f7";
        "FONT_FAMILY" = "JetBrainsMono Nerd Font";
      };
    };

    # Keybind overrides
    keybindOverrides = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Override default keybinds";
      example = {
        "terminal" = "SUPER, Return";
        "launcher" = "SUPER, Space";
        "screenshot" = "SUPER_SHIFT, S";
      };
    };

    # Widget configuration
    widgets = {
      bar = {
        enable = mkEnableOption "Top bar widget" // { default = true; };
        position = mkOption {
          type = types.enum [ "top" "bottom" ];
          default = "top";
          description = "Bar position";
        };
        modules = mkOption {
          type = types.listOf (types.enum [ 
            "workspaces" "window-title" "tray" "clock" "battery" 
            "network" "audio" "cpu" "memory" "temperature" 
          ]);
          default = [ "workspaces" "window-title" "tray" "clock" "battery" "network" "audio" ];
          description = "Modules to show in the bar";
        };
      };

      sidebar = {
        left = {
          enable = mkEnableOption "Left sidebar";
          width = mkOption {
            type = types.int;
            default = 350;
            description = "Sidebar width in pixels";
          };
          modules = mkOption {
            type = types.listOf (types.enum [ "ai-chat" "calendar" "todo" "system-info" "media" ]);
            default = [ "ai-chat" "calendar" "todo" "system-info" ];
            description = "Modules to show in left sidebar";
          };
        };

        right = {
          enable = mkEnableOption "Right sidebar";
          width = mkOption {
            type = types.int;
            default = 300;
            description = "Sidebar width in pixels";
          };
          modules = mkOption {
            type = types.listOf (types.enum [ "notifications" "controls" "weather" "calendar" ]);
            default = [ "notifications" "controls" ];
            description = "Modules to show in right sidebar";
          };
        };
      };
    };

    # Application overrides
    applications = {
      terminal = mkOption {
        type = types.str;
        default = "foot";
        description = "Default terminal application";
      };
      
      browser = mkOption {
        type = types.str;
        default = "firefox";
        description = "Default web browser";
      };
      
      fileManager = mkOption {
        type = types.str;
        default = "nautilus";
        description = "Default file manager";
      };
      
      editor = mkOption {
        type = types.str;
        default = "gedit";
        description = "Default text editor";
      };
    };
  };

  config = mkIf cfg.enable {
    # Apply custom configurations and create configuration files
    home.file = lib.mapAttrs' (name: value:
      lib.nameValuePair (".config/" + name) (
        if builtins.isPath value then
          { source = value; }
        else
          { text = value; }
      )
    ) cfg.customConfigs // {
      # Customization configuration file
      "dots-hyprland/customization.json".text = builtins.toJSON {
        templateOverrides = cfg.templateOverrides;
        keybindOverrides = cfg.keybindOverrides;
        widgets = cfg.widgets;
        applications = cfg.applications;
      };
      
      # Widget configuration integration
      "quickshell/ii/config/widgets.json".text = builtins.toJSON cfg.widgets;
    };

    # Install custom scripts and create hook scripts
    home.file = lib.mapAttrs' (name: script:
      lib.nameValuePair "${mainCfg.dataDir}/bin/${name}" {
        text = if builtins.isPath script.source then
          builtins.readFile script.source
        else
          script.source;
        executable = script.executable;
      }
    ) cfg.customScripts // {
      # Hook scripts
      "${mainCfg.dataDir}/hooks/pre-start.sh" = mkIf (cfg.hooks.preStart != "") {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          # Pre-start hook
          ${cfg.hooks.preStart}
        '';
        executable = true;
      };

      "${mainCfg.dataDir}/hooks/post-start.sh" = mkIf (cfg.hooks.postStart != "") {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          # Post-start hook
          ${cfg.hooks.postStart}
        '';
        executable = true;
      };

      "${mainCfg.dataDir}/hooks/color-change.sh" = mkIf (cfg.hooks.colorChange != "") {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          # Color change hook
          ${cfg.hooks.colorChange}
        '';
        executable = true;
      };

      "${mainCfg.dataDir}/hooks/before-shutdown.sh" = mkIf (cfg.hooks.beforeShutdown != "") {
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          # Before shutdown hook
          ${cfg.hooks.beforeShutdown}
        '';
        executable = true;
      };

    # Create customization configuration file
    home.file.".config/dots-hyprland/customization.json".text = builtins.toJSON {
      templateOverrides = cfg.templateOverrides;
      keybindOverrides = cfg.keybindOverrides;
      widgets = cfg.widgets;
      applications = cfg.applications;
    };

    # Custom keybind integration
    programs.dots-hyprland.hyprland.customConfig = mkIf (cfg.keybindOverrides != {}) (
      lib.concatMapStringsSep "\n" (name: 
        "bind = ${cfg.keybindOverrides.${name}}, exec, ${cfg.applications.${name} or name}"
      ) (lib.attrNames cfg.keybindOverrides)
    );

    # Widget configuration integration
    home.file.".config/quickshell/ii/config/widgets.json".text = builtins.toJSON cfg.widgets;

      # Customization helper script
      "${mainCfg.dataDir}/bin/customize" = {
      text = ''
        #!/usr/bin/env bash
        
        # dots-hyprland customization helper
        
        CUSTOMIZATION_DIR="${mainCfg.configDir}/dots-hyprland"
        HOOKS_DIR="${mainCfg.dataDir}/hooks"
        
        show_help() {
            echo "dots-hyprland customization helper"
            echo
            echo "Usage: customize [command] [options]"
            echo
            echo "Commands:"
            echo "  config          Edit main configuration"
            echo "  colors          Edit color scheme"
            echo "  keybinds        Edit keybinds"
            echo "  widgets         Configure widgets"
            echo "  hooks           Manage hooks"
            echo "  reload          Reload configuration"
            echo "  backup          Backup current configuration"
            echo "  restore         Restore configuration from backup"
            echo "  help            Show this help"
        }
        
        edit_config() {
            ''${EDITOR:-nano} "$CUSTOMIZATION_DIR/customization.json"
        }
        
        edit_colors() {
            echo "Color customization:"
            echo "1. Edit template overrides in customization.json"
            echo "2. Use color-generator script for dynamic colors"
            echo "3. Reload configuration to apply changes"
        }
        
        edit_keybinds() {
            echo "Keybind customization:"
            echo "Current keybind overrides:"
            ${pkgs.jq}/bin/jq -r '.keybindOverrides' "$CUSTOMIZATION_DIR/customization.json" 2>/dev/null || echo "No overrides set"
        }
        
        configure_widgets() {
            echo "Widget configuration:"
            ${pkgs.jq}/bin/jq -r '.widgets' "$CUSTOMIZATION_DIR/customization.json" 2>/dev/null || echo "Using defaults"
        }
        
        manage_hooks() {
            echo "Available hooks:"
            ls -la "$HOOKS_DIR/" 2>/dev/null || echo "No hooks found"
        }
        
        reload_config() {
            echo "Reloading dots-hyprland configuration..."
            
            # Run pre-start hook if it exists
            if [[ -x "$HOOKS_DIR/pre-start.sh" ]]; then
                "$HOOKS_DIR/pre-start.sh"
            fi
            
            # Reload Hyprland configuration
            ${pkgs.hyprland}/bin/hyprctl reload || true
            
            # Restart Quickshell
            ${pkgs.systemd}/bin/systemctl --user restart quickshell.service || true
            
            # Run post-start hook if it exists
            if [[ -x "$HOOKS_DIR/post-start.sh" ]]; then
                "$HOOKS_DIR/post-start.sh"
            fi
            
            echo "Configuration reloaded!"
        }
        
        backup_config() {
            local backup_dir="$HOME/.local/share/dots-hyprland/backups"
            local timestamp=$(date +%Y%m%d_%H%M%S)
            local backup_file="$backup_dir/config_$timestamp.tar.gz"
            
            mkdir -p "$backup_dir"
            
            tar -czf "$backup_file" -C "$HOME" \
                .config/dots-hyprland \
                .config/hypr \
                .config/quickshell \
                .local/share/dots-hyprland 2>/dev/null || true
            
            echo "Configuration backed up to: $backup_file"
        }
        
        restore_config() {
            local backup_dir="$HOME/.local/share/dots-hyprland/backups"
            
            echo "Available backups:"
            ls -la "$backup_dir"/*.tar.gz 2>/dev/null || {
                echo "No backups found"
                exit 1
            }
            
            echo "Enter backup filename to restore:"
            read -r backup_file
            
            if [[ -f "$backup_dir/$backup_file" ]]; then
                tar -xzf "$backup_dir/$backup_file" -C "$HOME"
                echo "Configuration restored from: $backup_file"
                echo "Run 'customize reload' to apply changes"
            else
                echo "Backup file not found: $backup_file"
                exit 1
            fi
        }
        
        case "''${1:-help}" in
            config) edit_config ;;
            colors) edit_colors ;;
            keybinds) edit_keybinds ;;
            widgets) configure_widgets ;;
            hooks) manage_hooks ;;
            reload) reload_config ;;
            backup) backup_config ;;
            restore) restore_config ;;
            help|*) show_help ;;
        esac
      '';
      executable = true;
    };
    };

    # Add script dependencies to packages
    home.packages = cfg.extraPackages ++ 
      (lib.flatten (lib.mapAttrsToList (name: script: script.dependencies) cfg.customScripts));

    # Apply environment variables
    home.sessionVariables = cfg.environmentVariables;

    # Custom keybind integration
    programs.dots-hyprland.hyprland.customConfig = mkIf (cfg.keybindOverrides != {}) (
      lib.concatMapStringsSep "\n" (name: 
        "bind = ${cfg.keybindOverrides.${name}}, exec, ${cfg.applications.${name} or name}"
      ) (lib.attrNames cfg.keybindOverrides)
    );

    # Desktop entry for customization tool
    xdg.desktopEntries.dots-hyprland-customize = {
      name = "Customize dots-hyprland";
      comment = "Customize your dots-hyprland desktop environment";
      exec = "${mainCfg.dataDir}/bin/customize config";
      icon = "preferences-desktop";
      categories = [ "Settings" "System" ];
      terminal = true;
    };
  };
}
