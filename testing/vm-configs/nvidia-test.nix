{ config, lib, pkgs, ... }:

{
  imports = [ ./basic-test.nix ];

  # Override for NVIDIA testing
  services.dots-hyprland.hardware = {
    nvidia = true;
    amd = false;
    intel = false;
    bluetooth = true;
    audio = true;
  };

  # NVIDIA-specific VM setup (if GPU passthrough available)
  virtualisation.qemu.options = [
    "-vga none"
    "-nographic"
    "-device vfio-pci,host=01:00.0" # GPU passthrough (if available)
  ];

  # NVIDIA-specific packages for testing
  environment.systemPackages = with pkgs; [
    nvidia-smi
    nvtop
    cudatoolkit
  ];

  # Additional NVIDIA testing configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false; # Use proprietary driver for testing
  };

  # Override hostname
  networking.hostName = "dots-hyprland-nvidia-test";
}
