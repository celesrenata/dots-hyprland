#!/usr/bin/env bash

# Quick package availability checker using nix search
set -euo pipefail

echo "🔍 Quick package availability check..."
echo "======================================"

# Function to check if a package exists using nix search
check_package() {
    local package=$1
    echo -n "Checking $package... "
    
    if nix search nixpkgs "$package" --json 2>/dev/null | jq -e "keys | length > 0" >/dev/null 2>&1; then
        echo "✅ Available"
        return 0
    else
        echo "❌ Not found"
        return 1
    fi
}

# Critical packages first
echo
echo "🚨 CRITICAL PACKAGES:"
echo "--------------------"
check_package "quickshell" || echo "   → CUSTOM DERIVATION NEEDED"

echo
echo "📦 HIGH PRIORITY:"
echo "----------------"
check_package "hyprland"
check_package "matugen"
check_package "fuzzel"
check_package "wlogout"

echo
echo "🎨 THEMING:"
echo "----------"
check_package "material-color-utilities"
check_package "materialyoucolor"

echo
echo "🐍 PYTHON PACKAGES:"
echo "------------------"
check_package "python3Packages.pillow"
check_package "python3Packages.psutil"
check_package "python3Packages.libsass"

echo
echo "======================================"
echo "✅ Quick check complete!"
