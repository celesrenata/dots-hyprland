# Example configuration with Material You theming enabled
{
  programs.dots-hyprland = {
    enable = true;
    style = "illogical-impulse";
    
    # Enable core components
    components = {
      hyprland = true;
      quickshell = true;
      theming = true;  # Enable Material You theming
      audio = true;
    };
    
    # Material You theming configuration
    theming = {
      enable = true;
      
      # Wallpaper settings
      wallpaperDirectory = "/home/user/Pictures/Wallpapers";
      defaultWallpaper = "/home/user/Pictures/Wallpapers/default.jpg";
      
      # Color scheme
      colorScheme = "dark";  # or "light" or "auto"
      contrast = 0.0;        # -1.0 to 1.0
      
      # Behavior
      autoReload = true;     # Reload apps when theme changes
      generateOnBoot = true; # Generate theme on first boot
      
      # Application theming
      applications = {
        gtk = true;          # Theme GTK apps
        qt = true;           # Theme Qt apps  
        terminal = true;     # Theme terminals
        launcher = true;     # Theme fuzzel launcher
        lockscreen = true;   # Theme hyprlock
      };
      
      # Wallpaper setter
      wallpaperSetter = "swww";  # or "hyprpaper"
    };
    
    # Hyprland configuration
    hyprland = {
      enable = true;
      
      # Appearance settings work with Material You
      appearance = {
        gaps.inner = 4;
        gaps.outer = 5;
        border.size = 1;
        rounding = 18;
        blur.enable = true;
        blur.size = 14;
        blur.passes = 3;
        shadow.enable = true;
        dimInactive = true;
      };
      
      # Animations
      animations.enable = true;
      
      # Gestures
      gestures.workspaceSwipe = true;
    };
  };
  
  # Shell aliases for easy theme management
  programs.bash.enable = true;  # This enables the theme-* aliases
}
