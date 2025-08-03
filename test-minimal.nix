# Minimal test configuration to isolate the conflict
{ config, lib, pkgs, ... }:

{
  home.username = "celes";
  home.homeDirectory = "/home/celes";
  home.stateVersion = "24.05";
  
  # Test with just one file
  home.file.".config/hypr/test.conf".text = "# Test file";
}
