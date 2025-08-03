{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.theming;
  mainCfg = config.programs.dots-hyprland;

  # Create matugen configuration
  matugenConfig = pkgs.writeText "matugen-config.toml" ''
    [config]
    version_check = false

    [templates.m3colors]
    input_path = '${./../../configs/matugen/templates/colors.json}'
    output_path = '${mainCfg.dataDir}/generated/colors.json'

    [templates.hyprland]
    input_path = '${./../../configs/matugen/templates/hyprland/colors.conf}'
    output_path = '~/.config/hypr/colors.conf'

    [templates.hyprlock]
    input_path = '${./../../configs/matugen/templates/hyprland/hyprlock.conf}'
    output_path = '~/.config/hypr/hyprlock.conf'

    [templates.fuzzel]
    input_path = '${./../../configs/matugen/templates/fuzzel/fuzzel_theme.ini}'
    output_path = '~/.config/fuzzel/fuzzel_theme.ini'

    [templates.foot]
    input_path = '${./../../configs/matugen/templates/foot/foot.ini}'
    output_path = '~/.config/foot/foot.ini'

    [templates.kitty]
    input_path = '${./../../configs/matugen/templates/kitty/kitty.conf}'
    output_path = '~/.config/kitty/kitty.conf'

    [templates.wlogout_style]
    input_path = '${./../../configs/matugen/templates/wlogout/style.css}'
    output_path = '~/.config/wlogout/style.css'

    [templates.gtk3]
    input_path = '${./../../configs/matugen/templates/gtk/gtk-colors.css}'
    output_path = '~/.config/gtk-3.0/gtk.css'

    [templates.gtk4]
    input_path = '${./../../configs/matugen/templates/gtk/gtk-colors.css}'
    output_path = '~/.config/gtk-4.0/gtk.css'

    [templates.kde_colors]
    input_path = '${./../../configs/matugen/templates/kde/color.txt}'
    output_path = '${mainCfg.dataDir}/generated/color.txt'

    [templates.wallpaper]
    input_path = '${./../../configs/matugen/templates/wallpaper.txt}'
    output_path = '${mainCfg.dataDir}/generated/wallpaper/path.txt'

    [templates.quickshell_colors]
    input_path = '${./../../configs/matugen/templates/quickshell/colors.qml}'
    output_path = '${mainCfg.dataDir}/generated/colors.qml'
  '';

  # Color generation script
  generateColorsScript = pkgs.writeShellScript "generate-material-colors" ''
    #!/usr/bin/env bash
    set -euo pipefail

    WALLPAPER="$1"
    MODE="''${2:-dark}"
    CONFIG_FILE="${matugenConfig}"
    DATA_DIR="${mainCfg.dataDir}"

    # Ensure directories exist
    mkdir -p "$DATA_DIR/generated/wallpaper"
    mkdir -p ~/.config/hypr
    mkdir -p ~/.config/fuzzel
    mkdir -p ~/.config/foot
    mkdir -p ~/.config/kitty
    mkdir -p ~/.config/wlogout
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0

    # Validate wallpaper exists
    if [[ ! -f "$WALLPAPER" ]]; then
      echo "Error: Wallpaper file '$WALLPAPER' not found"
      exit 1
    fi

    echo "🎨 Generating Material You colors from: $WALLPAPER"
    echo "🌙 Mode: $MODE"

    # Generate colors with matugen
    ${pkgs.matugen}/bin/matugen image "$WALLPAPER" \
      --mode "$MODE" \
      --type scheme-content \
      --contrast ${toString cfg.contrast} \
      --config "$CONFIG_FILE"

    # Store wallpaper path for reference
    echo "$WALLPAPER" > "$DATA_DIR/generated/wallpaper/path.txt"
    echo "$MODE" > "$DATA_DIR/generated/wallpaper/mode.txt"

    echo "✅ Material You theming complete!"

    # Reload applications if requested
    ${optionalString cfg.autoReload ''
      echo "🔄 Reloading applications..."
      
      # Reload Quickshell
      if pgrep -x qs >/dev/null || pgrep -x quickshell >/dev/null; then
        ${pkgs.systemd}/bin/systemctl --user reload-or-restart quickshell.service 2>/dev/null || true
      fi
      
      # Reload GTK applications
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
      
      # Send notification
      ${pkgs.libnotify}/bin/notify-send "Material You" "Theme updated from wallpaper" \
        --icon="preferences-desktop-theme" --timeout=3000 2>/dev/null || true
    ''}
  '';

  # Wallpaper switching script
  switchWallpaperScript = pkgs.writeShellScript "switch-wallpaper" ''
    #!/usr/bin/env bash
    set -euo pipefail

    WALLPAPER_DIR="''${1:-${cfg.wallpaperDirectory}}"
    MODE="''${2:-${cfg.colorScheme}}"

    if [[ ! -d "$WALLPAPER_DIR" ]]; then
      echo "Error: Wallpaper directory '$WALLPAPER_DIR' not found"
      exit 1
    fi

    # Find a random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

    if [[ -z "$WALLPAPER" ]]; then
      echo "Error: No wallpapers found in '$WALLPAPER_DIR'"
      exit 1
    fi

    echo "🖼️  Selected wallpaper: $(basename "$WALLPAPER")"

    # Set wallpaper with hyprpaper or swww
    if command -v swww >/dev/null 2>&1; then
      ${pkgs.swww}/bin/swww img "$WALLPAPER" --transition-type wipe --transition-duration 1
    elif command -v hyprpaper >/dev/null 2>&1; then
      hyprctl hyprpaper wallpaper ",$WALLPAPER"
    else
      echo "Warning: No wallpaper setter found (swww or hyprpaper)"
    fi

    # Generate colors
    ${generateColorsScript} "$WALLPAPER" "$MODE"
  '';

  # Theme mode toggle script
  toggleModeScript = pkgs.writeShellScript "toggle-theme-mode" ''
    #!/usr/bin/env bash
    set -euo pipefail

    DATA_DIR="${mainCfg.dataDir}"
    CURRENT_MODE_FILE="$DATA_DIR/generated/wallpaper/mode.txt"
    WALLPAPER_FILE="$DATA_DIR/generated/wallpaper/path.txt"

    # Read current mode and wallpaper
    if [[ -f "$CURRENT_MODE_FILE" ]]; then
      CURRENT_MODE=$(cat "$CURRENT_MODE_FILE")
    else
      CURRENT_MODE="dark"
    fi

    if [[ -f "$WALLPAPER_FILE" ]]; then
      WALLPAPER=$(cat "$WALLPAPER_FILE")
    else
      echo "Error: No wallpaper set. Use switch-wallpaper first."
      exit 1
    fi

    # Toggle mode
    if [[ "$CURRENT_MODE" == "dark" ]]; then
      NEW_MODE="light"
    else
      NEW_MODE="dark"
    fi

    echo "🌓 Switching from $CURRENT_MODE to $NEW_MODE mode"

    # Regenerate colors with new mode
    ${generateColorsScript} "$WALLPAPER" "$NEW_MODE"
  '';

in
{
  options.programs.dots-hyprland.theming = {
    enable = mkEnableOption "Material You theming system";

    # Wallpaper settings
    wallpaperDirectory = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/Pictures/Wallpapers";
      description = "Directory containing wallpapers";
      example = "/home/user/Pictures/Wallpapers";
    };

    defaultWallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Default wallpaper to use";
      example = "/home/user/Pictures/Wallpapers/default.jpg";
    };

    # Color scheme settings
    colorScheme = mkOption {
      type = types.enum [ "dark" "light" "auto" ];
      default = "dark";
      description = "Color scheme preference";
    };

    contrast = mkOption {
      type = types.float;
      default = 0.0;
      description = "Contrast adjustment (-1.0 to 1.0)";
    };

    # Behavior settings
    autoReload = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically reload applications when theme changes";
    };

    generateOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Generate theme colors on system boot";
    };

    # Application theming
    applications = {
      gtk = mkEnableOption "GTK application theming" // { default = true; };
      qt = mkEnableOption "Qt application theming" // { default = true; };
      terminal = mkEnableOption "Terminal theming" // { default = true; };
      launcher = mkEnableOption "Launcher theming" // { default = true; };
      lockscreen = mkEnableOption "Lock screen theming" // { default = true; };
    };

    # Wallpaper setter
    wallpaperSetter = mkOption {
      type = types.enum [ "swww" "hyprpaper" ];
      default = "swww";
      description = "Wallpaper setting application";
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    home.packages = with pkgs; [
      matugen                    # Color generation
      imagemagick               # Image processing
      (if cfg.wallpaperSetter == "swww" then swww else hyprpaper)
    ];

    # Create theme management scripts
    home.file = {
      "${mainCfg.dataDir}/bin/generate-colors" = {
        source = generateColorsScript;
        executable = true;
      };
      
      "${mainCfg.dataDir}/bin/switch-wallpaper" = {
        source = switchWallpaperScript;
        executable = true;
      };
      
      "${mainCfg.dataDir}/bin/toggle-theme-mode" = {
        source = toggleModeScript;
        executable = true;
      };
    };

    # Ensure directories exist
    home.file."${mainCfg.dataDir}/generated/.keep".text = "";
    home.file."${mainCfg.dataDir}/generated/wallpaper/.keep".text = "";

    # Generate initial theme if wallpaper is specified
    home.activation.generateInitialTheme = mkIf (cfg.defaultWallpaper != null && cfg.generateOnBoot) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [[ ! -f "${mainCfg.dataDir}/generated/colors.json" ]]; then
          echo "🎨 Generating initial Material You theme..."
          ${generateColorsScript} "${cfg.defaultWallpaper}" "${cfg.colorScheme}" || true
        fi
      ''
    );

    # Systemd service for wallpaper daemon (if using swww)
    systemd.user.services.swww = mkIf (cfg.wallpaperSetter == "swww") {
      Unit = {
        Description = "Swww wallpaper daemon";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Session variables for theming
    home.sessionVariables = {
      MATERIAL_YOU_DATA_DIR = mainCfg.dataDir;
      MATUGEN_CONFIG = matugenConfig;
    };

    # Shell aliases for easy theme management
    programs.bash.shellAliases = mkIf config.programs.bash.enable {
      "theme-switch" = "${switchWallpaperScript}";
      "theme-toggle" = "${toggleModeScript}";
      "theme-generate" = "${generateColorsScript}";
    };

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
      "theme-switch" = "${switchWallpaperScript}";
      "theme-toggle" = "${toggleModeScript}";
      "theme-generate" = "${generateColorsScript}";
    };

    programs.fish.shellAliases = mkIf config.programs.fish.enable {
      "theme-switch" = "${switchWallpaperScript}";
      "theme-toggle" = "${toggleModeScript}";
      "theme-generate" = "${generateColorsScript}";
    };
  };
}
