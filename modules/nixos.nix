{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dots-hyprland;
in
{
  options.services.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland system integration";

    # Display manager configuration
    displayManager = mkOption {
      type = types.enum [ "gdm" "sddm" "lightdm" ];
      default = "gdm";
      description = "Display manager to use";
    };

    # Hardware support configuration
    hardware = {
      nvidia = mkEnableOption "NVIDIA GPU support";
      amd = mkEnableOption "AMD GPU support";
      intel = mkEnableOption "Intel GPU support";
      bluetooth = mkEnableOption "Bluetooth support" // { default = true; };
      audio = mkEnableOption "Audio support" // { default = true; };
    };

    # Security configuration
    security = {
      polkit = mkEnableOption "PolicyKit support" // { default = true; };
      keyring = mkEnableOption "GNOME Keyring support" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    # Display manager configuration
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = mkIf (cfg.displayManager == "gdm") {
          enable = true;
          wayland = true;
        };
        sddm = mkIf (cfg.displayManager == "sddm") {
          enable = true;
          wayland.enable = true;
        };
        lightdm = mkIf (cfg.displayManager == "lightdm") {
          enable = true;
        };
      };
    };

    # Hyprland configuration
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Audio system - Phase 3 Priority
    security.rtkit.enable = mkIf cfg.hardware.audio true;
    services.pipewire = mkIf cfg.hardware.audio {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Bluetooth support
    hardware.bluetooth.enable = mkIf cfg.hardware.bluetooth true;
    services.blueman.enable = mkIf cfg.hardware.bluetooth true;

    # Network management
    networking.networkmanager.enable = true;

    # Security services
    security.polkit.enable = mkIf cfg.security.polkit true;
    services.gnome.gnome-keyring.enable = mkIf cfg.security.keyring true;

    # XDG Portal configuration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # Font configuration - Phase 3 Essential
    fonts.packages = with pkgs; [
      # Basic fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      
      # Icon fonts for widgets
      font-awesome
      material-design-icons
      
      # Programming fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
    ];

    # Graphics support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # NVIDIA specific configuration
    services.xserver.videoDrivers = mkIf cfg.hardware.nvidia [ "nvidia" ];
    hardware.nvidia = mkIf cfg.hardware.nvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };

    # AMD specific configuration
    services.xserver.videoDrivers = mkIf cfg.hardware.amd [ "amdgpu" ];

    # Intel specific configuration
    services.xserver.videoDrivers = mkIf cfg.hardware.intel [ "modesetting" ];

    # System packages needed for dots-hyprland
    environment.systemPackages = with pkgs; [
      # Core utilities
      wget curl git
      
      # Wayland utilities
      wl-clipboard
      wlr-randr
      
      # System tools
      htop
      neofetch
      
      # Development tools (optional)
      vim
      nano
    ];

    # Environment variables
    environment.sessionVariables = {
      # Wayland environment
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      
      # XDG configuration
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    # Systemd services
    systemd.user.services.hyprland-session = {
      description = "Hyprland session target";
      unitConfig = {
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    # User groups for hardware access
    users.groups.input = {};
    users.groups.video = {};
    users.groups.audio = {};

    # Udev rules for input devices
    services.udev.extraRules = ''
      # Allow users in input group to access input devices
      KERNEL=="event*", GROUP="input", MODE="0664"
      KERNEL=="js*", GROUP="input", MODE="0664"
    '';
  };
}
