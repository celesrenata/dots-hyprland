#!/usr/bin/env bash

# Improved package availability checker
set -euo pipefail

echo "🔍 Improved package availability check..."
echo "========================================"

# Function to check if a package exists using nix search
check_package() {
    local package=$1
    local description=${2:-""}
    echo -n "Checking $package... "
    
    if nix search nixpkgs "$package" --json 2>/dev/null | jq -e "keys | length > 0" >/dev/null 2>&1; then
        echo "✅ Available"
        return 0
    else
        echo "❌ Not found"
        return 1
    fi
}

# Function to check Python packages (they're versioned)
check_python_package() {
    local package=$1
    echo -n "Checking python3Packages.$package... "
    
    # Check for python312Packages first (most common)
    if nix search nixpkgs "python312Packages.$package" --json 2>/dev/null | jq -e "keys | length > 0" >/dev/null 2>&1; then
        echo "✅ Available (python312Packages.$package)"
        return 0
    elif nix search nixpkgs "python313Packages.$package" --json 2>/dev/null | jq -e "keys | length > 0" >/dev/null 2>&1; then
        echo "✅ Available (python313Packages.$package)"
        return 0
    else
        echo "❌ Not found"
        return 1
    fi
}

echo
echo "🚨 CRITICAL PACKAGES:"
echo "--------------------"
check_package "quickshell" || echo "   → CUSTOM DERIVATION NEEDED (HIGHEST PRIORITY)"

echo
echo "📦 CORE DEPENDENCIES:"
echo "--------------------"
check_package "hyprland"
check_package "hypridle"
check_package "hyprlock"
check_package "hyprpicker"
check_package "hyprsunset"
check_package "hyprutils"
check_package "matugen"
check_package "fuzzel"
check_package "wlogout"

echo
echo "🎨 THEMING & COLORS:"
echo "------------------"
check_package "material-color-utilities"
check_package "materialyoucolor"

echo
echo "🐍 PYTHON PACKAGES:"
echo "------------------"
check_python_package "pillow"
check_python_package "psutil"
check_python_package "libsass"
check_python_package "setuptools-scm"
check_python_package "wheel"
check_python_package "build"

echo
echo "🔊 AUDIO & MEDIA:"
echo "---------------"
check_package "cava"
check_package "pavucontrol-qt"
check_package "wireplumber"
check_package "playerctl"

echo
echo "🛠️ DEVELOPMENT TOOLS:"
echo "--------------------"
check_package "cmake"
check_package "meson"
check_package "clang"
check_package "sassc"

echo
echo "========================================"
echo "✅ Improved check complete!"
echo
echo "Summary:"
echo "- quickshell: NEEDS CUSTOM DERIVATION"
echo "- Most other packages: Available in nixpkgs"
echo "- Python packages: Available with version prefixes"
