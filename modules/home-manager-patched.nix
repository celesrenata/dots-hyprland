{ config, lib, pkgs, dots-hyprland, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland;
in
{
  imports = [
    ./python-environment.nix
    ./quickshell-patched.nix
    ./system-integration.nix
  ];

  options.programs.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland desktop environment with qs->root:/ patches";
    
    source = mkOption {
      type = types.path;
      default = dots-hyprland;
      description = "Source path for dots-hyprland";
    };
    
    enableDebugMode = mkEnableOption "Enable debug logging and verbose output";
  };

  config = mkIf cfg.enable {
    # Install all required packages (from our previous analysis)
    home.packages = with pkgs; [
      # Basic utilities
      axel bc coreutils cliphist cmake curl rsync wget ripgrep jq meson xdg-user-dirs
      
      # Hyprland ecosystem
      hypridle hyprcursor hyprland hyprland-qtutils hyprlang hyprlock
      hyprpicker hyprsunset hyprutils hyprwayland-scanner
      xdg-desktop-portal-hyprland wl-clipboard
      
      # Widget system
      quickshell fuzzel wlogout networkmanagerapplet translate-shell
      
      # Python system packages
      clang uv gtk4 libadwaita libsoup3 libportal-gtk4 gobject-introspection
      sassc opencv4
      
      # Additional tools
      glib # for gsettings
      libnotify # for notifications
    ];

    # Enable all components with patched quickshell
    programs.dots-hyprland.python.enable = true;
    programs.dots-hyprland.quickshell-patched.enable = true;
    programs.dots-hyprland.quickshell-patched.enableDebugLogging = cfg.enableDebugMode;
    programs.dots-hyprland.system.enable = true;

    # Copy other configuration files (non-quickshell)
    xdg.configFile = {
      # Copy hypr configuration
      "hypr" = {
        source = "${cfg.source}/.config/hypr";
        recursive = true;
      };
      
      # Copy other application configs
      "foot" = {
        source = "${cfg.source}/.config/foot";
        recursive = true;
      };
      
      "kitty" = {
        source = "${cfg.source}/.config/kitty";
        recursive = true;
      };
      
      "fuzzel" = {
        source = "${cfg.source}/.config/fuzzel";
        recursive = true;
      };
      
      "wlogout" = {
        source = "${cfg.source}/.config/wlogout";
        recursive = true;
      };
      
      "matugen" = {
        source = "${cfg.source}/.config/matugen";
        recursive = true;
      };
      
      # Copy illogical-impulse config
      "illogical-impulse" = {
        source = "${cfg.source}/.config/illogical-impulse";
        recursive = true;
      };
    };

    # Copy .local/share files
    home.file = {
      ".local/share/icons" = {
        source = "${cfg.source}/.local/share/icons";
        recursive = true;
      };
      
      ".local/share/konsole" = {
        source = "${cfg.source}/.local/share/konsole";
        recursive = true;
      };
    };

    # Set critical environment variables
    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${config.home.homeDirectory}/.local/state/quickshell/.venv";
    };

    # Ensure XDG directories exist
    xdg.enable = true;
    xdg.userDirs.enable = true;
    
    # Debug information
    home.activation.dotsHyprlandInfo = mkIf cfg.enableDebugMode (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "🚀 DOTS-HYPRLAND SETUP COMPLETE!"
        echo "Source: ${cfg.source}"
        echo "Python venv: $ILLOGICAL_IMPULSE_VIRTUAL_ENV"
        echo "Quickshell config: ~/.config/quickshell (patched with root:/ imports)"
        echo ""
        echo "To test: quickshell -c ii"
        echo "To debug: QT_LOGGING_RULES='quickshell.qsintercept.debug=true' quickshell -c ii"
      ''
    );
  };
}
