{ config, lib, pkgs, ... }:

{
  # Simple test configuration without importing our custom module
  # (since it's already imported in the flake)

  # Enable dots-hyprland system integration
  services.dots-hyprland = {
    enable = true;
    
    # Basic hardware configuration
    hardware = {
      nvidia = false;
      amd = false;
      intel = true;
      bluetooth = false;
      audio = true;
    };
    
    # Display manager
    displayManager = "gdm";
    
    # Basic security
    security = {
      polkit = true;
      keyring = true;
      firewall = false;  # Disable for testing
    };
    
    # Network
    networking = {
      networkmanager = true;
      wireless = false;
    };
  };

  # Test user configuration
  users.users.testuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ];
    password = "test123";
  };

  # Basic system configuration
  system.stateVersion = "24.05";
  
  # Networking
  networking.hostName = "dots-hyprland-test";

  # Boot configuration (minimal)
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # File systems (placeholder)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
