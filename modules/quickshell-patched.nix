{ config, lib, pkgs, dots-hyprland, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.quickshell-patched;
  mainCfg = config.programs.dots-hyprland;
  
  # Import our patcher
  qsPatcher = import ../lib/qs-to-root-patcher.nix { inherit lib pkgs; };
  
  # Patch the original dots-hyprland quickshell configuration
  patchedQuickshellConfig = qsPatcher.patchDotsHyprlandConfig dots-hyprland;
  
in
{
  options.programs.dots-hyprland.quickshell-patched = {
    enable = mkEnableOption "Patched Quickshell configuration with root:/ imports";
    
    enableDebugLogging = mkEnableOption "Enable debug logging for patch verification";
  };

  config = mkIf cfg.enable {
    # Install the patched quickshell configuration
    xdg.configFile."quickshell" = {
      source = patchedQuickshellConfig;
      recursive = true;
    };
    
    # Debug: Show what files were patched
    home.activation.showQuickshellPatches = mkIf cfg.enableDebugLogging (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "🔧 QUICKSHELL PATCHES APPLIED:"
        echo "Original source: ${dots-hyprland}/.config/quickshell"
        echo "Patched config: ${patchedQuickshellConfig}"
        echo "Applied qs -> root:/ import patches to all QML files"
        
        # Show a sample of what was patched
        if [ -f "${patchedQuickshellConfig}/ii/shell.qml" ]; then
          echo "Sample patches in shell.qml:"
          grep -n "root:/" "${patchedQuickshellConfig}/ii/shell.qml" | head -3 || echo "No root:/ imports found"
        fi
      ''
    );
    
    # Ensure quickshell package is available
    home.packages = with pkgs; [
      quickshell
    ];
    
    # Set up environment for quickshell
    home.sessionVariables = {
      # Ensure the Python virtual environment is available
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${config.home.homeDirectory}/.local/state/quickshell/.venv";
    };
  };
}
