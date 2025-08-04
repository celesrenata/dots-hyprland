{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.transparency;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.transparency = {
    enable = mkEnableOption "Transparency and blur configuration" // { default = true; };

    # Global transparency settings (matching AGS structure)
    global = {
      enable = mkEnableOption "Global transparency mode";
      
      mode = mkOption {
        type = types.enum [ "opaque" "transparent" ];
        default = "opaque";
        description = "Global transparency mode for shell elements";
      };
    };

    # Terminal transparency settings
    terminal = {
      opacity = mkOption {
        type = types.int;
        default = 100;
        description = "Terminal opacity percentage (0-100)";
      };
      
      applyToAllTerminals = mkOption {
        type = types.bool;
        default = true;
        description = "Apply opacity to all terminal applications";
      };
    };

    # Hyprland blur settings (matching your AGS options)
    blur = {
      enable = mkEnableOption "Hyprland blur effects";
      
      xray = mkOption {
        type = types.bool;
        default = true;
        description = "Enable X-ray mode for better performance";
      };
      
      size = mkOption {
        type = types.int;
        default = 8;
        description = "Blur radius (1-1000)";
      };
      
      passes = mkOption {
        type = types.int;
        default = 4;
        description = "Number of blur passes (1-10)";
      };
      
      noise = mkOption {
        type = types.float;
        default = 0.0117;
        description = "Blur noise amount";
      };
      
      contrast = mkOption {
        type = types.float;
        default = 0.8916;
        description = "Blur contrast";
      };
      
      brightness = mkOption {
        type = types.float;
        default = 0.8172;
        description = "Blur brightness";
      };
      
      vibrancy = mkOption {
        type = types.float;
        default = 0.1696;
        description = "Blur vibrancy";
      };
      
      vibrancyDarkness = mkOption {
        type = types.float;
        default = 0.0;
        description = "Blur vibrancy darkness";
      };
    };

    # Window-specific transparency rules
    windowRules = mkOption {
      type = types.listOf (types.submodule {
        options = {
          class = mkOption {
            type = types.str;
            description = "Window class pattern";
          };
          
          opacity = mkOption {
            type = types.float;
            description = "Window opacity (0.0-1.0)";
          };
          
          opacityInactive = mkOption {
            type = types.nullOr types.float;
            default = null;
            description = "Inactive window opacity (0.0-1.0)";
          };
        };
      });
      default = [];
      description = "Window-specific opacity rules";
      example = [
        { class = "foot"; opacity = 0.9; }
        { class = "kitty"; opacity = 0.95; opacityInactive = 0.8; }
      ];
    };

    # Advanced settings
    advanced = {
      enableColorModeFile = mkOption {
        type = types.bool;
        default = true;
        description = "Create AGS-compatible colormode.txt file";
      };
      
      colorModeFilePath = mkOption {
        type = types.str;
        default = "${config.xdg.cacheHome}/ags/user/colormode.txt";
        description = "Path to colormode.txt file";
      };
      
      terminalTransparencyFilePath = mkOption {
        type = types.str;
        default = "${config.xdg.cacheHome}/ags/user/generated/terminal/transparency";
        description = "Path to terminal transparency file";
      };
    };
  };

  config = mkIf cfg.enable {
    # Hyprland blur configuration
    wayland.windowManager.hyprland.settings = mkIf mainCfg.components.hyprland {
      decoration = {
        blur = mkIf cfg.blur.enable {
          enabled = true;
          xray = cfg.blur.xray;
          size = cfg.blur.size;
          passes = cfg.blur.passes;
          noise = cfg.blur.noise;
          contrast = cfg.blur.contrast;
          brightness = cfg.blur.brightness;
          vibrancy = cfg.blur.vibrancy;
          vibrancy_darkness = cfg.blur.vibrancyDarkness;
        };
      };
      
      # Window opacity rules
      windowrulev2 = map (rule: 
        if rule.opacityInactive != null then
          "opacity ${toString rule.opacity} ${toString rule.opacityInactive},class:^(${rule.class})$"
        else
          "opacity ${toString rule.opacity},class:^(${rule.class})$"
      ) cfg.windowRules;
    };

    # Terminal configuration (foot)
    programs.foot = mkIf (mainCfg.applications.terminal == "foot") {
      settings = {
        main = {
          alpha = cfg.terminal.opacity / 100.0;
        };
      };
    };

    # Create AGS-compatible files
    home.file = mkMerge [
      (mkIf cfg.advanced.enableColorModeFile {
        "${cfg.advanced.colorModeFilePath}" = {
          text = ''
            dark
            ${cfg.global.mode}
          '';
        };
      })
      
      {
        "${cfg.advanced.terminalTransparencyFilePath}" = {
          text = toString cfg.terminal.opacity;
        };
      }
    ];

    # Quickshell transparency configuration
    xdg.configFile."quickshell/ii/modules/settings/transparency-config.json" = {
      text = builtins.toJSON {
        globalTransparency = cfg.global.enable;
        globalMode = cfg.global.mode;
        terminalOpacity = cfg.terminal.opacity;
        blur = {
          enabled = cfg.blur.enable;
          xray = cfg.blur.xray;
          size = cfg.blur.size;
          passes = cfg.blur.passes;
          noise = cfg.blur.noise;
          contrast = cfg.blur.contrast;
          brightness = cfg.blur.brightness;
          vibrancy = cfg.blur.vibrancy;
          vibrancyDarkness = cfg.blur.vibrancyDarkness;
        };
        windowRules = cfg.windowRules;
        advanced = cfg.advanced;
      };
    };

    # Scripts for transparency management
    home.packages = [
      (pkgs.writeShellScriptBin "dots-transparency" ''
        #!/usr/bin/env bash
        # Transparency management script (AGS compatibility)
        
        CACHE_DIR="${config.xdg.cacheHome}/ags/user"
        COLORMODE_FILE="$CACHE_DIR/colormode.txt"
        TERMINAL_TRANSPARENCY_FILE="$CACHE_DIR/generated/terminal/transparency"
        
        case "$1" in
          "set-global")
            mode="$2"
            if [[ "$mode" != "opaque" && "$mode" != "transparent" ]]; then
              echo "Usage: $0 set-global [opaque|transparent]"
              exit 1
            fi
            
            mkdir -p "$CACHE_DIR"
            if [[ ! -f "$COLORMODE_FILE" ]]; then
              echo "dark" > "$COLORMODE_FILE"
              echo "$mode" >> "$COLORMODE_FILE"
            else
              sed -i "2s/.*/$mode/" "$COLORMODE_FILE"
            fi
            
            # Apply to quickshell
            quickshell ipc call transparencySettings setTransparency $([ "$mode" = "transparent" ] && echo "true" || echo "false")
            ;;
            
          "set-terminal")
            opacity="$2"
            if [[ ! "$opacity" =~ ^[0-9]+$ ]] || [[ "$opacity" -lt 0 ]] || [[ "$opacity" -gt 100 ]]; then
              echo "Usage: $0 set-terminal [0-100]"
              exit 1
            fi
            
            mkdir -p "$(dirname "$TERMINAL_TRANSPARENCY_FILE")"
            echo "$opacity" > "$TERMINAL_TRANSPARENCY_FILE"
            
            # Apply to quickshell
            quickshell ipc call transparencySettings setTerminalOpacity "$opacity"
            
            # Apply to foot terminal
            alpha=$(echo "scale=2; $opacity / 100" | bc)
            if [[ -f "$HOME/.config/foot/foot.ini" ]]; then
              sed -i "s/^alpha=.*/alpha=$alpha/" "$HOME/.config/foot/foot.ini" || echo "alpha=$alpha" >> "$HOME/.config/foot/foot.ini"
            fi
            ;;
            
          "set-blur")
            enabled="$2"
            if [[ "$enabled" != "true" && "$enabled" != "false" ]]; then
              echo "Usage: $0 set-blur [true|false]"
              exit 1
            fi
            
            hyprctl keyword decoration:blur:enabled $([ "$enabled" = "true" ] && echo "1" || echo "0")
            quickshell ipc call transparencySettings setBlur "$enabled"
            ;;
            
          "get-settings")
            quickshell ipc call transparencySettings getSettings
            ;;
            
          "reload")
            quickshell ipc call transparencySettings reload
            ;;
            
          *)
            echo "Usage: $0 [set-global|set-terminal|set-blur|get-settings|reload] [args...]"
            echo ""
            echo "Commands:"
            echo "  set-global [opaque|transparent]  - Set global transparency mode"
            echo "  set-terminal [0-100]             - Set terminal opacity percentage"
            echo "  set-blur [true|false]            - Enable/disable blur effects"
            echo "  get-settings                     - Get current settings"
            echo "  reload                           - Reload settings from files"
            exit 1
            ;;
        esac
      '')
    ];
  };
}
