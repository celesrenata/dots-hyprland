{ lib, pkgs }:

let
  generateAdvancedColors = { wallpaper, mode ? "dark", contrast ? 0.0 }: 
    pkgs.writeShellScript "generate-advanced-colors" ''
      #!/usr/bin/env bash
      
      WALLPAPER="${wallpaper}"
      MODE="${mode}"
      CONTRAST="${toString contrast}"
      CACHE_DIR="$HOME/.cache/dots-hyprland/colors"
      
      mkdir -p "$CACHE_DIR"
      
      # Generate base colors with matugen
      ${pkgs.matugen}/bin/matugen image "$WALLPAPER" \
        --mode "$MODE" \
        --type scheme-content \
        --contrast "$CONTRAST" \
        --json > "$CACHE_DIR/base-colors.json"
      
      # Generate extended color palette
      python3 ${./color-processor.py} \
        --input "$CACHE_DIR/base-colors.json" \
        --output "$CACHE_DIR" \
        --mode "$MODE"
      
      # Generate application-specific themes
      ${generateGtkTheme}/bin/generate-gtk-theme "$CACHE_DIR"
      ${generateQtTheme}/bin/generate-qt-theme "$CACHE_DIR"
      ${generateTerminalTheme}/bin/generate-terminal-theme "$CACHE_DIR"
      ${generateHyprlandTheme}/bin/generate-hyprland-theme "$CACHE_DIR"
      
      # Apply themes
      ${applyThemes}/bin/apply-themes "$CACHE_DIR"
      
      echo "Material You theming complete"
    '';

  generateGtkTheme = pkgs.writeShellScriptBin "generate-gtk-theme" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    GTK_DIR="$HOME/.config/gtk-3.0"
    
    mkdir -p "$GTK_DIR"
    
    # Read colors
    PRIMARY=$(${pkgs.jq}/bin/jq -r '.colors.primary' "$CACHE_DIR/base-colors.json")
    SURFACE=$(${pkgs.jq}/bin/jq -r '.colors.surface' "$CACHE_DIR/base-colors.json")
    
    # Generate GTK CSS
    cat > "$GTK_DIR/gtk.css" << EOF
    @define-color accent_color $PRIMARY;
    @define-color accent_bg_color $PRIMARY;
    @define-color accent_fg_color white;
    @define-color destructive_color #ff6b6b;
    @define-color destructive_bg_color #ff6b6b;
    @define-color destructive_fg_color white;
    @define-color success_color #51cf66;
    @define-color success_bg_color #51cf66;
    @define-color success_fg_color white;
    @define-color warning_color #ffd43b;
    @define-color warning_bg_color #ffd43b;
    @define-color warning_fg_color black;
    @define-color error_color #ff6b6b;
    @define-color error_bg_color #ff6b6b;
    @define-color error_fg_color white;
    @define-color window_bg_color $SURFACE;
    @define-color window_fg_color white;
    @define-color view_bg_color $SURFACE;
    @define-color view_fg_color white;
    @define-color headerbar_bg_color $SURFACE;
    @define-color headerbar_fg_color white;
    @define-color headerbar_border_color rgba(255,255,255,0.1);
    @define-color headerbar_backdrop_color $SURFACE;
    @define-color headerbar_shade_color rgba(0,0,0,0.1);
    @define-color card_bg_color rgba(255,255,255,0.05);
    @define-color card_fg_color white;
    @define-color card_shade_color rgba(0,0,0,0.1);
    @define-color dialog_bg_color $SURFACE;
    @define-color dialog_fg_color white;
    @define-color popover_bg_color $SURFACE;
    @define-color popover_fg_color white;
    @define-color shade_color rgba(0,0,0,0.1);
    @define-color scrollbar_outline_color rgba(255,255,255,0.1);
    EOF
  '';

  generateQtTheme = pkgs.writeShellScriptBin "generate-qt-theme" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    QT_DIR="$HOME/.config/qt5ct"
    
    mkdir -p "$QT_DIR"
    
    # Read colors
    PRIMARY=$(${pkgs.jq}/bin/jq -r '.colors.primary' "$CACHE_DIR/base-colors.json")
    SURFACE=$(${pkgs.jq}/bin/jq -r '.colors.surface' "$CACHE_DIR/base-colors.json")
    
    # Generate Qt theme
    cat > "$QT_DIR/colors/dots-hyprland.conf" << EOF
    [ColorScheme]
    active_colors=$PRIMARY, $SURFACE, #ffffff, #000000, #808080, #c0c0c0, #000000, #ffffff, #000000, #ffffff, $SURFACE, #000000, $PRIMARY, #ffffff, #0000ff, #ff00ff, $SURFACE, #000000, #ffffdc, #000000, #000000
    disabled_colors=#808080, $SURFACE, #ffffff, #000000, #808080, #c0c0c0, #808080, #ffffff, #808080, #ffffff, $SURFACE, #000000, #808080, #ffffff, #0000ff, #ff00ff, $SURFACE, #000000, #ffffdc, #000000, #000000
    inactive_colors=$PRIMARY, $SURFACE, #ffffff, #000000, #808080, #c0c0c0, #000000, #ffffff, #000000, #ffffff, $SURFACE, #000000, $PRIMARY, #ffffff, #0000ff, #ff00ff, $SURFACE, #000000, #ffffdc, #000000, #000000
    EOF
  '';

  generateTerminalTheme = pkgs.writeShellScriptBin "generate-terminal-theme" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    
    # Read colors
    PRIMARY=$(${pkgs.jq}/bin/jq -r '.colors.primary' "$CACHE_DIR/base-colors.json")
    SURFACE=$(${pkgs.jq}/bin/jq -r '.colors.surface' "$CACHE_DIR/base-colors.json")
    BACKGROUND=$(${pkgs.jq}/bin/jq -r '.colors.background' "$CACHE_DIR/base-colors.json")
    FOREGROUND=$(${pkgs.jq}/bin/jq -r '.colors.onBackground' "$CACHE_DIR/base-colors.json")
    
    # Generate foot theme
    cat > "$CACHE_DIR/foot-colors.ini" << EOF
    [colors]
    background=$BACKGROUND
    foreground=$FOREGROUND
    regular0=15161e
    regular1=f7768e
    regular2=9ece6a
    regular3=e0af68
    regular4=7aa2f7
    regular5=$PRIMARY
    regular6=7dcfff
    regular7=a9b1d6
    bright0=414868
    bright1=f7768e
    bright2=9ece6a
    bright3=e0af68
    bright4=7aa2f7
    bright5=$PRIMARY
    bright6=7dcfff
    bright7=c0caf5
    EOF
  '';

  generateHyprlandTheme = pkgs.writeShellScriptBin "generate-hyprland-theme" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    
    # Read colors
    PRIMARY=$(${pkgs.jq}/bin/jq -r '.colors.primary' "$CACHE_DIR/base-colors.json")
    SURFACE=$(${pkgs.jq}/bin/jq -r '.colors.surface' "$CACHE_DIR/base-colors.json")
    
    # Generate Hyprland colors
    cat > "$CACHE_DIR/hyprland-colors.conf" << EOF
    # Material You colors for Hyprland
    \$accent = rgb($PRIMARY)
    \$surface = rgb($SURFACE)
    \$background = rgb(1a1b26)
    \$foreground = rgb(c0caf5)
    
    general {
        col.active_border = \$accent
        col.inactive_border = \$surface
    }
    EOF
  '';

  applyThemes = pkgs.writeShellScriptBin "apply-themes" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    
    # Reload GTK applications
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    
    # Reload Qt applications
    export QT_STYLE_OVERRIDE="kvantum"
    
    # Reload Quickshell
    ${pkgs.systemd}/bin/systemctl --user reload-or-restart quickshell.service || true
    
    # Send notification
    ${pkgs.libnotify}/bin/notify-send "Material You" "Theme updated successfully" \
      --icon="preferences-desktop-theme" || true
  '';

  # Color processor Python script
  colorProcessor = pkgs.writeText "color-processor.py" ''
    #!/usr/bin/env python3
    import json
    import sys
    import argparse
    import colorsys
    
    def hex_to_rgb(hex_color):
        """Convert hex color to RGB tuple"""
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    
    def rgb_to_hex(rgb):
        """Convert RGB tuple to hex color"""
        return '#{:02x}{:02x}{:02x}'.format(int(rgb[0]), int(rgb[1]), int(rgb[2]))
    
    def generate_palette(base_color, mode='dark'):
        """Generate a complete color palette from base color"""
        r, g, b = hex_to_rgb(base_color)
        h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
        
        palette = {}
        
        # Generate variations
        if mode == 'dark':
            palette['primary'] = base_color
            palette['primary_variant'] = rgb_to_hex(colorsys.hsv_to_rgb(h, s*0.8, v*0.8))
            palette['secondary'] = rgb_to_hex(colorsys.hsv_to_rgb((h+0.1)%1, s*0.6, v*0.9))
            palette['background'] = '#1a1b26'
            palette['surface'] = '#24283b'
            palette['error'] = '#f7768e'
            palette['on_primary'] = '#ffffff'
            palette['on_secondary'] = '#ffffff'
            palette['on_background'] = '#c0caf5'
            palette['on_surface'] = '#c0caf5'
            palette['on_error'] = '#ffffff'
        else:
            palette['primary'] = base_color
            palette['primary_variant'] = rgb_to_hex(colorsys.hsv_to_rgb(h, s*1.2, v*0.7))
            palette['secondary'] = rgb_to_hex(colorsys.hsv_to_rgb((h+0.1)%1, s*0.4, v*0.6))
            palette['background'] = '#ffffff'
            palette['surface'] = '#f7f7f7'
            palette['error'] = '#b00020'
            palette['on_primary'] = '#ffffff'
            palette['on_secondary'] = '#000000'
            palette['on_background'] = '#000000'
            palette['on_surface'] = '#000000'
            palette['on_error'] = '#ffffff'
        
        return palette
    
    def main():
        parser = argparse.ArgumentParser(description='Process Material You colors')
        parser.add_argument('--input', required=True, help='Input JSON file')
        parser.add_argument('--output', required=True, help='Output directory')
        parser.add_argument('--mode', default='dark', help='Color mode (dark/light)')
        
        args = parser.parse_args()
        
        try:
            with open(args.input, 'r') as f:
                data = json.load(f)
            
            # Extract primary color
            primary = data.get('colors', {}).get('primary', '#bb9af7')
            
            # Generate extended palette
            palette = generate_palette(primary, args.mode)
            
            # Save extended palette
            with open(f"{args.output}/extended-palette.json", 'w') as f:
                json.dump(palette, f, indent=2)
            
            print("Color processing complete")
            
        except Exception as e:
            print(f"Error processing colors: {e}")
            sys.exit(1)
    
    if __name__ == '__main__':
        main()
  '';
in
{
  inherit generateAdvancedColors generateGtkTheme generateQtTheme 
          generateTerminalTheme generateHyprlandTheme applyThemes;
  
  # Make color processor available
  colorProcessor = colorProcessor;
}
