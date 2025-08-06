# Python Virtual Environment for dots-hyprland
# This replicates the installer's Python setup exactly
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.python;
  mainCfg = config.programs.dots-hyprland;
  
  # Virtual environment setup script that replicates installer behavior
  setupVenvScript = pkgs.writeShellScript "setup-dots-hyprland-venv" ''
    #!/usr/bin/env bash
    set -e
    
    VENV_PATH="$HOME/.local/state/quickshell/.venv"
    
    echo "🐍 Setting up dots-hyprland Python virtual environment..."
    echo "📁 Target: $VENV_PATH"
    
    # Create directory structure
    mkdir -p "$(dirname "$VENV_PATH")"
    
    # Remove existing venv if it exists
    if [[ -d "$VENV_PATH" ]]; then
      echo "🗑️  Removing existing virtual environment..."
      rm -rf "$VENV_PATH"
    fi
    
    # Create virtual environment with Python 3.12 (installer requirement)
    echo "🏗️  Creating Python 3.12 virtual environment..."
    ${pkgs.python312}/bin/python -m venv "$VENV_PATH" --prompt .venv
    
    # Activate and install exact requirements from installer
    echo "📦 Installing Python packages..."
    source "$VENV_PATH/bin/activate"
    
    # Install exact versions from scriptdata/requirements.txt
    pip install --no-cache-dir \
      build==1.2.2.post1 \
      cffi==1.17.1 \
      libsass==0.23.0 \
      material-color-utilities==0.2.1 \
      materialyoucolor==2.0.10 \
      numpy==2.2.2 \
      packaging==24.2 \
      pillow==11.1.0 \
      psutil==6.1.1 \
      pycparser==2.22 \
      pyproject-hooks==1.2.0 \
      pywayland==0.4.18 \
      setproctitle==1.3.4 \
      setuptools==80.9.0 \
      setuptools-scm==8.1.0 \
      wheel==0.45.1
    
    deactivate
    
    echo "✅ Python virtual environment setup complete!"
    echo "🔗 Environment variable: ILLOGICAL_IMPULSE_VIRTUAL_ENV=$VENV_PATH"
  '';
  
  # Test script to verify the Python environment works
  testVenvScript = pkgs.writeShellScript "test-dots-hyprland-venv" ''
    #!/usr/bin/env bash
    
    VENV_PATH="$HOME/.local/state/quickshell/.venv"
    
    echo "🧪 Testing dots-hyprland Python virtual environment..."
    
    if [[ ! -d "$VENV_PATH" ]]; then
      echo "❌ Virtual environment not found at $VENV_PATH"
      exit 1
    fi
    
    source "$VENV_PATH/bin/activate"
    
    # Test critical packages
    echo "📦 Testing Python packages..."
    python -c "import material_color_utilities; print('✅ material-color-utilities')" || echo "❌ material-color-utilities"
    python -c "import materialyoucolor; print('✅ materialyoucolor')" || echo "❌ materialyoucolor"
    python -c "import pywayland; print('✅ pywayland')" || echo "❌ pywayland"
    python -c "import PIL; print('✅ pillow')" || echo "❌ pillow"
    python -c "import numpy; print('✅ numpy')" || echo "❌ numpy"
    python -c "import psutil; print('✅ psutil')" || echo "❌ psutil"
    
    deactivate
    
    echo "🎉 Python environment test complete!"
  '';
in
{
  options.programs.dots-hyprland.python = {
    enable = mkEnableOption "Python virtual environment for dots-hyprland";
    
    venvPath = mkOption {
      type = types.str;
      default = "$HOME/.local/state/quickshell/.venv";
      description = "Path to Python virtual environment";
    };
    
    autoSetup = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically set up virtual environment on activation";
    };
  };

  config = mkIf cfg.enable {
    # Install system Python and required build dependencies
    home.packages = with pkgs; [
      python312
      python312Packages.pip
      python312Packages.virtualenv
      
      # System dependencies for Python packages (from illogical-impulse-python PKGBUILD)
      clang
      gtk4
      libadwaita
      libsoup_3
      libportal-gtk4
      gobject-introspection
      sassc
      opencv4
      
      # Development tools
      pkg-config
      cairo
      gdk-pixbuf
      glib
    ];

    # Set up virtual environment on Home Manager activation
    home.activation.setupDotsHyprlandVenv = mkIf cfg.autoSetup (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${setupVenvScript}
      ''
    );

    # Set critical environment variable
    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = cfg.venvPath;
    };
    
    # Add test script to user packages
    home.packages = [
      (pkgs.writeShellScriptBin "test-dots-hyprland-venv" ''
        ${testVenvScript}
      '')
    ];
  };
}
