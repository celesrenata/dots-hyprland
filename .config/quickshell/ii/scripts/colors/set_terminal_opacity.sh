#!/bin/bash
# Script to set terminal opacity from settings UI

OPACITY=$1
if [ -z "$OPACITY" ]; then
    echo "Usage: $0 <opacity_percentage>"
    exit 1
fi

echo "Setting terminal opacity to $OPACITY%" >> /tmp/terminal_debug.log

# Update term_alpha in applycolor.sh
sed -i "s/^term_alpha=.*/term_alpha=$OPACITY/" ~/.config/quickshell/scripts/colors/applycolor.sh

# Apply the changes
~/.config/quickshell/scripts/colors/applycolor.sh

echo "Terminal opacity set to $OPACITY% at $(date)" >> /tmp/terminal_debug.log
