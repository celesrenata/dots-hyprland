# FHS Environment for dots-hyprland
# This creates a traditional Linux filesystem environment where
# the original dots-hyprland can run unchanged
{ lib
, pkgs
, buildFHSUserEnv
, quickshell
, dots-hyprland-source ? null
}:

buildFHSUserEnv {
  name = "dots-hyprland-fhs";
  
  # All the packages dots-hyprland expects in traditional locations
  targetPkgs = pkgs: with pkgs; [
    # Core Hyprland ecosystem (from our Phase 1 analysis)
    hyprland
    hypridle
    hyprcursor
    hyprland-qtutils
    hyprlang
    hyprlock
    hyprpicker
    hyprsunset
    hyprutils
    hyprwayland-scanner
    xdg-desktop-portal-hyprland
    wl-clipboard
    
    # Quickshell (the key component)
    quickshell.packages.${pkgs.system}.default
    
    # UI and application packages
    fuzzel
    wlogout
    networkmanagerapplet
    translate-shell
    
    # Core utilities (from PKGBUILD analysis)
    axel bc coreutils cliphist cmake curl rsync wget ripgrep jq meson xdg-user-dirs
    
    # Python environment for scripts
    python3
    python3Packages.pip
    python3Packages.requests
    python3Packages.pillow
    python3Packages.numpy
    
    # Audio system
    pipewire
    wireplumber
    pavucontrol
    playerctl
    
    # Fonts (critical for UI)
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    material-design-icons
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    
    # Theme and color tools
    matugen
    
    # Development tools
    git
    nodejs
    npm
    
    # System integration
    glib # for gsettings
    polkit
    dbus
  ];
  
  # Multi-arch packages if needed
  multiPkgs = pkgs: with pkgs; [
    # Add any 32-bit packages if required
  ];
  
  # Environment setup - make it look like a traditional Linux system
  profile = ''
    # XDG directories
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_CACHE_HOME=$HOME/.cache
    export XDG_STATE_HOME=$HOME/.local/state
    
    # Ensure directories exist
    mkdir -p $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_CACHE_HOME $XDG_STATE_HOME
    
    # Qt/QML environment
    export QT_PLUGIN_PATH=/usr/lib/qt6/plugins
    export QML2_IMPORT_PATH=/usr/lib/qt6/qml
    
    # Python path for scripts
    export PYTHONPATH=/usr/lib/python3.11/site-packages:$PYTHONPATH
    
    # Font configuration
    export FONTCONFIG_PATH=/etc/fonts
    
    # D-Bus session
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
    
    # Wayland
    export WAYLAND_DISPLAY=wayland-1
    export XDG_SESSION_TYPE=wayland
    
    echo "🚀 dots-hyprland FHS environment ready!"
    echo "📁 Config: $XDG_CONFIG_HOME"
    echo "📦 Data: $XDG_DATA_HOME"
  '';
  
  # The main run script
  runScript = pkgs.writeScript "dots-hyprland-start" ''
    #!/bin/bash
    set -e
    
    echo "🎯 Starting dots-hyprland in FHS environment..."
    
    # Ensure quickshell config exists
    if [[ ! -d "$XDG_CONFIG_HOME/quickshell" ]]; then
      echo "❌ No quickshell configuration found at $XDG_CONFIG_HOME/quickshell"
      echo "💡 Please install dots-hyprland configuration first"
      exit 1
    fi
    
    # Change to quickshell config directory
    cd "$XDG_CONFIG_HOME/quickshell"
    
    # Start quickshell with proper environment
    echo "🚀 Launching quickshell..."
    exec quickshell "$@"
  '';
  
  meta = with lib; {
    description = "FHS environment for running dots-hyprland desktop environment";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ "dots-hyprland-nixos team" ];
  };
}
