# Main Home Manager module for dots-hyprland
# Replicates the installer workflow exactly
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland;
in
{
  imports = [
    ./python-environment.nix
    ./configuration.nix
  ];

  options.programs.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland desktop environment";
    
    source = mkOption {
      type = types.path;
      description = "Source path for clean dots-hyprland configuration";
      example = "inputs.dots-hyprland";
    };
    
    packageSet = mkOption {
      type = types.enum [ "minimal" "essential" "all" ];
      default = "essential";
      description = "Which package set to install";
    };
  };

  config = mkIf cfg.enable {
    # Install packages based on selected set
    home.packages = 
      let
        packageSets = import ../packages/dots-hyprland-packages.nix { inherit lib pkgs; };
      in
      if cfg.packageSet == "minimal" then packageSets.minimalPackages
      else if cfg.packageSet == "essential" then packageSets.essentialPackages
      else packageSets.allPackages;

    # Enable Python virtual environment (CRITICAL)
    programs.dots-hyprland.python = {
      enable = true;
      autoSetup = true;
    };

    # Enable configuration management
    programs.dots-hyprland.configuration = {
      enable = true;
      source = cfg.source;
    };

    # Set critical environment variable (replicating installer)
    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "$HOME/.local/state/quickshell/.venv";
    };

    # Ensure XDG directories exist (installer requirement)
    xdg.enable = true;
    xdg.userDirs.enable = true;
    
    # Add quickshell from official flake to packages
    # Note: This should be provided by the flake input
  };
}
