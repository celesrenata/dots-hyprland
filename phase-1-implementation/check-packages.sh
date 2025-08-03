#!/usr/bin/env bash

# Package availability checker for NixOS
# This script checks if packages are available in nixpkgs

set -euo pipefail

echo "🔍 Checking package availability in nixpkgs..."
echo "================================================"

# Function to check if a package exists
check_package() {
    local package=$1
    local description=${2:-""}
    
    if nix-env -qaP | grep -q "nixpkgs\.${package}$" 2>/dev/null; then
        echo "✅ $package - Available"
        return 0
    elif nix-env -qaP | grep -q "$package" 2>/dev/null; then
        echo "⚠️  $package - Similar package found:"
        nix-env -qaP | grep "$package" | head -3
        return 1
    else
        echo "❌ $package - Not found"
        return 1
    fi
}

# Function to check Python packages
check_python_package() {
    local package=$1
    
    if nix-env -qaP | grep -q "python.*${package}" 2>/dev/null; then
        echo "✅ python3Packages.$package - Available"
        return 0
    else
        echo "❌ python3Packages.$package - Not found"
        return 1
    fi
}

echo
echo "📦 Basic Dependencies:"
echo "----------------------"
check_package "axel"
check_package "bc"
check_package "coreutils"
check_package "cliphist"
check_package "cmake"
check_package "curl"
check_package "rsync"
check_package "wget"
check_package "ripgrep"
check_package "jq"
check_package "meson"
check_package "xdg-user-dirs"

echo
echo "🪟 Hyprland Ecosystem:"
echo "----------------------"
check_package "hypridle"
check_package "hyprcursor"
check_package "hyprland"
check_package "hyprland-qtutils"
check_package "hyprlang"
check_package "hyprlock"
check_package "hyprpicker"
check_package "hyprsunset"
check_package "hyprutils"
check_package "hyprwayland-scanner"
check_package "xdg-desktop-portal-hyprland"
check_package "wl-clipboard"

echo
echo "🎛️ Widget System:"
echo "----------------"
check_package "fuzzel"
check_package "glib"
check_package "networkmanagerapplet"
check_package "translate-shell"
check_package "wlogout"
echo "❌ quickshell - CUSTOM DERIVATION NEEDED"

echo
echo "🔊 Audio System:"
echo "---------------"
check_package "cava"
check_package "pavucontrol-qt"
check_package "wireplumber"
check_package "libdbusmenu-gtk3"
check_package "playerctl"

echo
echo "🎨 Fonts & Themes:"
echo "-----------------"
check_package "eza"
check_package "fish"
check_package "fontconfig"
check_package "kitty"
check_package "matugen"
check_package "starship"
check_package "jetbrains-mono"
check_package "twemoji-color-font"

echo
echo "🐍 Python Dependencies:"
echo "----------------------"
check_package "clang"
check_package "gtk4"
check_package "libadwaita"
check_package "libsoup_3"
check_package "gobject-introspection"
check_package "sassc"
check_package "opencv4"

echo
echo "📸 Screen Capture:"
echo "-----------------"
check_package "slurp"
check_package "swappy"
check_package "tesseract"
check_package "wf-recorder"

echo
echo "🛠️ Toolkit:"
echo "----------"
check_package "kdialog"
check_package "upower"
check_package "wtype"
check_package "ydotool"

echo
echo "🐍 Python Packages:"
echo "------------------"
check_python_package "build"
check_python_package "pillow"
check_python_package "setuptools-scm"
check_python_package "wheel"
check_python_package "psutil"
check_python_package "libsass"

echo
echo "================================================"
echo "✅ Package availability check complete!"
echo
echo "Next steps:"
echo "1. Create quickshell derivation (CRITICAL)"
echo "2. Check questionable packages manually"
echo "3. Create derivations for missing packages"
