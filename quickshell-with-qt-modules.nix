{ pkgs }:

let
  # Create a quickshell with all the necessary Qt modules
  quickshellWithModules = pkgs.quickshell.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ (with pkgs.qt6; [
      # Missing Qt modules that dots-hyprland needs
      qt5compat        # For Qt5Compat.GraphicalEffects
      qtpositioning    # For QtPositioning (weather services)
      qtmultimedia     # For multimedia features
      qtwebengine      # For web-based features
    ]);
    
    # Ensure Qt modules are available at runtime
    qtWrapperArgs = [
      "--prefix QML2_IMPORT_PATH : ${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "--prefix QML2_IMPORT_PATH : ${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "--prefix QML2_IMPORT_PATH : ${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtQmlPrefix}"
    ];
  });
in
quickshellWithModules
