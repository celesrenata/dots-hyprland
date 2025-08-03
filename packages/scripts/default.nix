{ lib, pkgs, writeShellScriptBin }:

let
  # Basic utility scripts for dots-hyprland
  quickshell-reload = writeShellScriptBin "quickshell-reload" ''
    #!/usr/bin/env bash
    # Reload Quickshell configuration
    
    echo "🔄 Reloading Quickshell..."
    
    if systemctl --user is-active quickshell.service >/dev/null 2>&1; then
      systemctl --user reload-or-restart quickshell.service
      echo "✅ Quickshell reloaded successfully"
    else
      echo "❌ Quickshell service is not running"
      exit 1
    fi
  '';

  dots-hyprland-info = writeShellScriptBin "dots-hyprland-info" ''
    #!/usr/bin/env bash
    # Display dots-hyprland system information
    
    echo "🎨 dots-hyprland System Information"
    echo "=================================="
    echo
    
    echo "📦 Package Versions:"
    echo "  Quickshell: $(quickshell --version 2>/dev/null || echo 'Not found')"
    echo "  Hyprland: $(hyprctl version 2>/dev/null | head -1 || echo 'Not found')"
    echo
    
    echo "🔧 Services Status:"
    echo "  Quickshell: $(systemctl --user is-active quickshell.service 2>/dev/null || echo 'inactive')"
    echo "  Hypridle: $(systemctl --user is-active hypridle.service 2>/dev/null || echo 'inactive')"
    echo
    
    echo "📁 Configuration Paths:"
    echo "  Config: ''${DOTS_HYPRLAND_CONFIG:-$HOME/.config}"
    echo "  Cache: ''${DOTS_HYPRLAND_CACHE:-$HOME/.cache/dots-hyprland}"
    echo "  Data: ''${DOTS_HYPRLAND_DATA:-$HOME/.local/share/dots-hyprland}"
    echo
    
    echo "🎯 Style: ''${DOTS_HYPRLAND_STYLE:-illogical-impulse}"
  '';

  dots-hyprland-setup = writeShellScriptBin "dots-hyprland-setup" ''
    #!/usr/bin/env bash
    # Initial setup script for dots-hyprland
    
    echo "🚀 Setting up dots-hyprland..."
    
    # Create necessary directories
    mkdir -p "''${DOTS_HYPRLAND_CACHE:-$HOME/.cache/dots-hyprland}"
    mkdir -p "''${DOTS_HYPRLAND_DATA:-$HOME/.local/share/dots-hyprland}"
    
    echo "📁 Created cache and data directories"
    
    # Start services if not running
    if ! systemctl --user is-active quickshell.service >/dev/null 2>&1; then
      echo "🔄 Starting Quickshell service..."
      systemctl --user start quickshell.service
    fi
    
    echo "✅ dots-hyprland setup complete!"
    echo "💡 Run 'dots-hyprland-info' to see system status"
  '';

in
pkgs.symlinkJoin {
  name = "dots-hyprland-scripts";
  paths = [
    quickshell-reload
    dots-hyprland-info
    dots-hyprland-setup
  ];
  
  meta = with lib; {
    description = "Utility scripts for dots-hyprland";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
