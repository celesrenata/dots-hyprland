#!/nix/store/6klllvhvq5aawjbg02dsixg02f0v933r-bash-5.2p26/bin/bash

# Check if sway is running
if ! pgrep -x sway > /dev/null; then
  echo "Sway is not running"
  exit 1
fi


# Get the current workspace number
current=$(swaymsg -t get_workspaces | gojq '.[] | select(.focused==true) | .num')

# Check if a number was passed as an argument
if [[ "$1" =~ ^[+-]?[0-9]+$ ]]; then
  new_workspace=$((current + $1))
else
  new_workspace=$((current + 1))
fi

# Check if the new workspace number is out of bounds
if [[ $new_workspace -lt 1 ]]; then
  exit 0
fi

# Switch to the new workspace
if [[ $2 == 'move' ]]; then
  swaymsg move container to workspace $new_workspace
else 
  swaymsg workspace $new_workspace
fi
