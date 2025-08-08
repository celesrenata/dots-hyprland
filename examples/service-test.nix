# Test configuration for quickshell service with staging
{ config, lib, pkgs, ... }:

{
  imports = [ ../modules/home-manager.nix ];

  programs.dots-hyprland = {
    enable = true;
    mode = "writable";
    source = /tmp/dots-hyprland; # Use our test source
    packageSet = "essential";
    
    writable = {
      stagingDir = ".configstaging";
      setupScript = "initialSetup.sh";
      backupExisting = true;
      symlinkMode = false; # Copy files for safety
    };
  };

  # Home Manager required settings
  home.username = "testuser";
  home.homeDirectory = "/home/testuser";
  home.stateVersion = "24.05";
}
