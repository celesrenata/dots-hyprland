#!/usr/bin/env bash

# Quick color generation script for dots-hyprland
# This bypasses the complex original script and generates colors directly

WALLPAPER="${1:-$HOME/.config/quickshell/assets/images/default_wallpaper.png}"
COLORS_DIR="$HOME/.local/state/quickshell/user/generated"

echo "Generating Material You colors from: $WALLPAPER"

# Ensure directory exists
mkdir -p "$COLORS_DIR"

# Generate colors using matugen
if command -v matugen >/dev/null 2>&1; then
    matugen image "$WALLPAPER" --mode dark --type scheme-content --json hex > "$COLORS_DIR/colors.json"
    echo "✅ Colors generated successfully at: $COLORS_DIR/colors.json"
    echo "File size: $(wc -c < "$COLORS_DIR/colors.json") bytes"
else
    echo "❌ matugen not found. Install with: nix profile install nixpkgs#matugen"
    exit 1
fi

# Restart quickshell if running
if pgrep quickshell >/dev/null; then
    echo "🔄 Restarting quickshell to apply new colors..."
    pkill quickshell
    sleep 1
    echo "Start quickshell manually to see the new colors"
else
    echo "ℹ️  Start quickshell to see the new colors"
fi
