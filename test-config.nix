# Test configuration for dots-hyprland installer replication
{ config, lib, pkgs, ... }:

{
  imports = [ ./modules/home-manager.nix ];

  # Basic Home Manager setup
  home.username = "celes";
  home.homeDirectory = "/home/celes";
  home.stateVersion = "24.05";

  # Enable dots-hyprland with installer replication
  programs.dots-hyprland = {
    enable = true;
    source = builtins.fetchGit {
      url = "https://github.com/end-4/dots-hyprland";
      # Use latest commit for testing
    };
    packageSet = "essential"; # Start with essential packages
  };

  # Allow unfree packages (needed for some dependencies)
  nixpkgs.config.allowUnfree = true;
}
