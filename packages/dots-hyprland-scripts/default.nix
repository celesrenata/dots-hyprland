{ lib, stdenv, makeWrapper, writeShellScriptBin
, wf-recorder, slurp, jq, libnotify, wl-clipboard, bc
, fuzzel, hyprland, grim, nautilus
}:

stdenv.mkDerivation rec {
  pname = "dots-hyprland-scripts";
  version = "1.0.0";

  src = ../../scripts;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    wf-recorder slurp jq libnotify wl-clipboard bc
    fuzzel hyprland grim nautilus
  ];

  installPhase = ''
    mkdir -p $out/bin
    
    # Install scripts
    cp fuzzel-emoji.sh $out/bin/
    cp record.sh $out/bin/
    cp zoom.sh $out/bin/
    
    # Make executable
    chmod +x $out/bin/*
    
    # Wrap scripts with proper PATH
    for script in $out/bin/*; do
      wrapProgram "$script" \
        --prefix PATH : ${lib.makeBinPath [
          wf-recorder slurp jq libnotify wl-clipboard bc
          fuzzel hyprland grim nautilus
        ]}
    done
  '';

  meta = with lib; {
    description = "Essential scripts for dots-hyprland desktop environment";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
