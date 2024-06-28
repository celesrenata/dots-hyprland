#!/nix/store/6klllvhvq5aawjbg02dsixg02f0v933r-bash-5.2p26/bin/bash
hyprctl dispatch "$1" $(((($(hyprctl activeworkspace -j | gojq -r .id) - 1)  / 10) * 10 + $2))
