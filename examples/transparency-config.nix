# Example configuration showing transparency and blur options
# This replicates your AGS transparency settings in NixOS/Home Manager

{ config, lib, pkgs, ... }:

{
  programs.dots-hyprland = {
    enable = true;
    style = "illogical-impulse";
    
    # Enable transparency module
    transparency = {
      enable = true;
      
      # Global transparency settings (matches AGS toggle)
      global = {
        enable = true;  # Enable the transparency system
        mode = "transparent";  # or "opaque" - matches AGS colormode.txt
      };
      
      # Terminal transparency (matches AGS terminal opacity slider)
      terminal = {
        opacity = 90;  # 0-100, matches your AGS slider
        applyToAllTerminals = true;
      };
      
      # Hyprland blur settings (matches your AGS blur options)
      blur = {
        enable = true;  # Matches AGS "Blur" toggle
        xray = true;    # Matches AGS "X-ray" toggle (performance optimization)
        size = 8;       # Matches AGS "Size" spinbutton (1-1000)
        passes = 4;     # Matches AGS "Passes" spinbutton (1-10)
        
        # Advanced blur settings (AGS doesn't expose these, but they're available)
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancyDarkness = 0.0;
      };
      
      # Window-specific opacity rules (extends AGS functionality)
      windowRules = [
        { class = "foot"; opacity = 0.9; }
        { class = "kitty"; opacity = 0.95; opacityInactive = 0.8; }
        { class = "code"; opacity = 0.95; }
        { class = "firefox"; opacity = 1.0; }  # Keep browser opaque
      ];
      
      # AGS compatibility settings
      advanced = {
        enableColorModeFile = true;  # Creates ~/.cache/ags/user/colormode.txt
        # Paths match AGS structure for compatibility
        colorModeFilePath = "${config.xdg.cacheHome}/ags/user/colormode.txt";
        terminalTransparencyFilePath = "${config.xdg.cacheHome}/ags/user/generated/terminal/transparency";
      };
    };
    
    # Other dots-hyprland settings
    components = {
      hyprland = true;
      quickshell = true;
      theming = true;
    };
    
    features = {
      overview = true;
      sidebar = true;
      notifications = true;
      mediaControls = true;
    };
  };
}

# Usage Examples:
#
# 1. Command line control (matches AGS functionality):
#    dots-transparency set-global transparent
#    dots-transparency set-terminal 85
#    dots-transparency set-blur true
#
# 2. Quickshell IPC control:
#    quickshell ipc call transparencySettings setTransparency true
#    quickshell ipc call transparencySettings setTerminalOpacity 85
#    quickshell ipc call transparencySettings setBlur true
#
# 3. Interactive UI:
#    Super+Ctrl+S  - Open settings window
#    Super+Ctrl+E  - Open effects tab directly
#
# 4. Quick keybinds:
#    Super+Ctrl+T       - Enable transparency
#    Super+Ctrl+Shift+T - Disable transparency
#    Super+Ctrl+B       - Enable blur
#    Super+Ctrl+Shift+B - Disable blur
#    Super+Ctrl+=       - Increase terminal opacity
#    Super+Ctrl+-       - Decrease terminal opacity
