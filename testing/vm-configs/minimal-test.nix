{ config, lib, pkgs, ... }:

{
  imports = [ ./basic-test.nix ];

  # Minimal configuration for resource-constrained testing
  virtualisation = {
    memorySize = 2048;  # Reduced memory
    # cores = 2;        # This option doesn't exist in NixOS
    qemu.options = [
      "-smp 2"  # Set CPU cores this way
    ];
  };

  # Minimal dots-hyprland configuration
  services.dots-hyprland = {
    enable = true;
    
    # Minimal hardware support
    hardware = {
      nvidia = false;
      amd = false;
      intel = true;
      bluetooth = false;
      audio = false;  # Disable audio for minimal test
      printing = false;
    };
    
    # Basic display manager
    displayManager = "gdm";
    
    # Minimal security
    security = {
      polkit = true;
      keyring = false;
      firewall = false;
      apparmor = false;
    };
    
    # Basic networking
    networking = {
      networkmanager = true;
      wireless = false;
      vpn = false;
    };
    
    # No development tools
    development.enable = false;
  };

  # Minimal Home Manager configuration
  home-manager.users.testuser = {
    programs.dots-hyprland = {
      enable = true;
      style = "illogical-impulse";
      
      # Minimal components
      components = {
        hyprland = true;
        quickshell = true;
        theming = false;
        ai = false;
        audio = false;
      };
      
      # Minimal features
      features = {
        overview = true;
        sidebar = false;
        notifications = false;
        mediaControls = false;
        screenCorners = false;
        onScreenKeyboard = false;
        cheatsheet = false;
      };
    };
  };

  # Minimal package set
  environment.systemPackages = with pkgs; [
    htop
    neofetch
    git
  ];

  # Override hostname
  networking.hostName = "dots-hyprland-minimal-test";
}
