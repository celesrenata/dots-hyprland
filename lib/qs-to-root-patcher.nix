{ lib, pkgs }:

let
  # Convert qs.* imports to root:/ equivalents
  # Based on GitHub issue #1666 workaround: "Changing every mention of qs to its 'root:/' equivalent works"
  
  patchQsImports = content: 
    let
      # Convert qs.modules.* imports to root:/modules/*
      step1 = builtins.replaceStrings 
        [ "import qs.modules.common.functions"
          "import qs.modules.common.widgets" 
          "import qs.modules.common"
          "import qs.services"
          "import qs"
        ]
        [ "import \"root:/modules/common/functions\""
          "import \"root:/modules/common/widgets\""
          "import \"root:/modules/common\""
          "import \"root:/services\""
          "import \"root:/\""
        ]
        content;
    in
    step1;

  # Process a single QML file
  patchQmlFile = sourceFile: 
    let
      originalContent = builtins.readFile sourceFile;
      patchedContent = patchQsImports originalContent;
    in
    pkgs.writeText (baseNameOf sourceFile) patchedContent;

  # Process an entire directory tree
  patchQmlDirectory = sourceDir: 
    pkgs.runCommand "patched-quickshell-config" {} ''
      # Copy the entire directory structure
      cp -r ${sourceDir} $out
      chmod -R u+w $out
      
      # Find and patch all QML files
      find $out -name "*.qml" -type f | while read file; do
        echo "Patching QML file: $file"
        
        # Apply qs -> root:/ patches
        ${pkgs.gnused}/bin/sed -i \
          -e 's|import qs\.modules\.common\.functions|import "root:/modules/common/functions"|g' \
          -e 's|import qs\.modules\.common\.widgets|import "root:/modules/common/widgets"|g' \
          -e 's|import qs\.modules\.common|import "root:/modules/common"|g' \
          -e 's|import qs\.services|import "root:/services"|g' \
          -e 's|^import qs$|import "root:/"|g' \
          "$file"
        
        echo "Patched: $file"
      done
      
      echo "QML patching complete!"
    '';

  # Test if a file needs patching
  needsPatching = file:
    let
      content = builtins.readFile file;
    in
    builtins.match ".*import qs[.].*" content != null ||
    builtins.match ".*import qs$.*" content != null;

in
{
  inherit patchQsImports patchQmlFile patchQmlDirectory needsPatching;
  
  # Main function to patch dots-hyprland configuration
  patchDotsHyprlandConfig = dotsHyprlandSource:
    patchQmlDirectory "${dotsHyprlandSource}/.config/quickshell";
}
