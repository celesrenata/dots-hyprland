{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.packages;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.packages = {
    enable = mkEnableOption "Package management" // { default = true; };

    # Package sets based on Phase 1 dependency analysis
    sets = {
      core = mkEnableOption "Core packages" // { default = true; };
      hyprland = mkEnableOption "Hyprland ecosystem packages" // { default = true; };
      widgets = mkEnableOption "Widget system packages" // { default = true; };
      audio = mkEnableOption "Audio packages" // { default = true; };
      themes = mkEnableOption "Theme packages" // { default = true; };
      applications = mkEnableOption "Application packages";
      fonts = mkEnableOption "Font packages" // { default = true; };
      development = mkEnableOption "Development packages";
    };

    extra = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Package names to exclude from installation";
    };
  };

  config = mkIf cfg.enable {
    home.packages = let
      selectedPackages = 
        # Core utilities - expanded for system monitoring
        (optionals cfg.sets.core (with pkgs; [
          curl wget git ripgrep jq
          htop btop procps # System monitoring
          playerctl # MPRIS control
          libnotify # Notifications
        ])) ++
        
        # Hyprland ecosystem packages
        (optionals cfg.sets.hyprland (with pkgs; [
          wl-clipboard
          hyprpicker hypridle hyprlock
          xdg-desktop-portal-hyprland
        ])) ++
        
        # Widget system packages - minimal set
        (optionals cfg.sets.widgets (with pkgs; [
          fuzzel libnotify
        ])) ++
        
        # Audio packages - expanded for MPRIS and system monitoring
        (optionals cfg.sets.audio (with pkgs; [
          pavucontrol playerctl
          pipewire wireplumber
          pulseaudio # for pactl command
        ])) ++
        
        # Application packages - minimal set
        (optionals cfg.sets.applications (with pkgs; [
          foot # just one terminal for testing
        ])) ++
        
        # Font packages - expanded with icon themes
        (optionals cfg.sets.fonts (with pkgs; [
          noto-fonts
          adwaita-icon-theme
          papirus-icon-theme
          material-design-icons
          font-awesome
        ])) ++
        
        # Theme packages - icon and cursor themes
        (optionals cfg.sets.themes (with pkgs; [
          adwaita-icon-theme
          papirus-icon-theme
          material-design-icons
          font-awesome
          gnome.adwaita-icon-theme
        ])) ++
        
        # Extra packages
        cfg.extra;
    in
      # Filter out excluded packages
      lib.filter (pkg: 
        !(lib.elem (pkg.pname or pkg.name or "unknown") cfg.exclude)
      ) selectedPackages;
  };
}
