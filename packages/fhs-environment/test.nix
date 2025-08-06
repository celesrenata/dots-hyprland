# Test script for FHS environment
{ pkgs }:

pkgs.writeShellScriptBin "test-fhs-environment" ''
  #!/bin/bash
  
  echo "🧪 Testing dots-hyprland FHS environment..."
  
  # Test 1: Check if we're in FHS environment
  echo "📁 Testing filesystem structure..."
  ls -la /usr/bin/python3 2>/dev/null && echo "✅ Python in /usr/bin" || echo "❌ Python not in /usr/bin"
  ls -la /usr/lib/qt6 2>/dev/null && echo "✅ Qt6 in /usr/lib" || echo "❌ Qt6 not in /usr/lib"
  
  # Test 2: Check quickshell availability
  echo "🔧 Testing quickshell..."
  which quickshell && echo "✅ quickshell found" || echo "❌ quickshell not found"
  quickshell --version 2>/dev/null && echo "✅ quickshell runs" || echo "❌ quickshell fails"
  
  # Test 3: Check Hyprland tools
  echo "🪟 Testing Hyprland ecosystem..."
  which hyprctl && echo "✅ hyprctl found" || echo "❌ hyprctl not found"
  which hypridle && echo "✅ hypridle found" || echo "❌ hypridle not found"
  which hyprlock && echo "✅ hyprlock found" || echo "❌ hyprlock not found"
  
  # Test 4: Check Python environment
  echo "🐍 Testing Python environment..."
  python3 -c "import sys; print(f'✅ Python {sys.version}')" 2>/dev/null || echo "❌ Python import failed"
  python3 -c "import requests; print('✅ requests module')" 2>/dev/null || echo "❌ requests module missing"
  
  # Test 5: Check environment variables
  echo "🌍 Testing environment variables..."
  echo "XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
  echo "XDG_DATA_HOME: $XDG_DATA_HOME"
  echo "QML2_IMPORT_PATH: $QML2_IMPORT_PATH"
  
  echo "🎉 FHS environment test complete!"
''
