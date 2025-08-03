{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.fonts;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.fonts = {
    enable = mkEnableOption "Font configuration" // { default = true; };
  };

  config = mkIf cfg.enable {
    # Font packages
    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      material-design-icons
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
    ];
    
    # TODO: Implement font configuration for applications
    # TODO: Implement icon font integration for widgets
  };
}
