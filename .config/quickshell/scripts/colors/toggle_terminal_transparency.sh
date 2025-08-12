#!/usr/bin/env bash
# Script to toggle terminal transparency

TRANSPARENCY_FILE="$HOME/.local/state/quickshell/user/generated/terminal/transparency"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$TRANSPARENCY_FILE")"

# Read current state or default to transparent
if [ -f "$TRANSPARENCY_FILE" ]; then
    current_state=$(cat "$TRANSPARENCY_FILE")
else
    current_state="transparent"
fi

# Toggle the state
if [ "$current_state" = "transparent" ]; then
    new_state="opaque"
else
    new_state="transparent"
fi

# Write new state and apply
echo "$new_state" > "$TRANSPARENCY_FILE"
~/.config/quickshell/scripts/colors/applycolor.sh

echo "Terminal transparency toggled from $current_state to $new_state"
