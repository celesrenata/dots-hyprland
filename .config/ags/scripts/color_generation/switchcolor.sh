#!/nix/store/6klllvhvq5aawjbg02dsixg02f0v933r-bash-5.2p26/bin/bash

if [ "$1" == "--pick" ]; then
  color=$(hyprpicker --no-fancy)
else
  color=$(cut -f1 "${HOME}/.cache/ags/user/color.txt")
fi

# Generate colors for ags n stuff
"$HOME"/.config/ags/scripts/color_generation/colorgen.sh "${color}" --apply
