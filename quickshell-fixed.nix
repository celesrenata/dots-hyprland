with import <nixpkgs> {};

let
  # Get the original quickshell from the flake
  quickshellOriginal = (import (fetchTarball "https://github.com/outfoxxed/quickshell/archive/main.tar.gz")).packages.${system}.default;
  
  # Create a wrapper that includes the missing Qt modules
  quickshellWithQt = pkgs.symlinkJoin {
    name = "quickshell-with-qt-modules";
    paths = [ quickshellOriginal ];
    
    buildInputs = with pkgs; [ makeWrapper ];
    
    postBuild = ''
      # Create QML import paths that include the missing Qt modules
      QML_PATHS="${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtpositioning}/lib/qt-6/qml"
      
      # Wrap quickshell to include the QML import paths
      wrapProgram $out/bin/quickshell \
        --set QML2_IMPORT_PATH "$QML_PATHS" \
        --set QML_IMPORT_PATH "$QML_PATHS"
    '';
  };
in
quickshellWithQt
