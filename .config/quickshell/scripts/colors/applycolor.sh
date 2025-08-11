#!/usr/bin/env bash

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"
CACHE_DIR="$XDG_CACHE_HOME/quickshell"
STATE_DIR="$XDG_STATE_HOME/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

term_alpha=80
# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$STATE_DIR"/user/generated ]; then
  mkdir -p "$STATE_DIR"/user/generated
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

colornames=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f1)
colorstrings=$(cat $STATE_DIR/user/generated/material_colors.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
IFS=$'\n'
colorlist=($colornames)     # Array of color names
colorvalues=($colorstrings) # Array of color values

apply_term() {
  # Check if terminal escape sequence template exists
  if [ ! -f "$SCRIPT_DIR/terminal/sequences.txt" ]; then
    echo "Template file not found for Terminal. Skipping that."
    return
  fi
  # Copy template
  mkdir -p "$STATE_DIR"/user/generated/terminal
  cp "$SCRIPT_DIR/terminal/sequences.txt" "$STATE_DIR"/user/generated/terminal/sequences.txt
  # Apply colors
  for i in "${!colorlist[@]}"; do
    sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$STATE_DIR"/user/generated/terminal/sequences.txt
  done

  sed -i "s/\$alpha/$term_alpha/g" "$STATE_DIR/user/generated/terminal/sequences.txt"

  for file in /dev/pts/*; do
    if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
      {
      cat "$STATE_DIR"/user/generated/terminal/sequences.txt >"$file"
      } & disown || true
    fi
  done
}

apply_qt() {
  sh "$CONFIG_DIR/scripts/kvantum/materialQT.sh"          # generate kvantum theme
  python "$CONFIG_DIR/scripts/kvantum/changeAdwColors.py" # apply config colors
}

apply_foot() {
  # Check if foot template exists
  if [ ! -f "$SCRIPT_DIR/foot/foot.ini" ]; then
    echo "Template file not found for Foot. Skipping that."
    return
  fi
  
  # Copy template
  mkdir -p "$STATE_DIR/user/generated/foot"
  cp "$SCRIPT_DIR/foot/foot.ini" "$STATE_DIR/user/generated/foot/foot.ini"
  
  # Apply colors (skip non-color variables like $darkmode, $transparent)
  for i in "${!colorlist[@]}"; do
    # Skip variables that don't start with color names or contain special values
    if [[ "${colorlist[$i]}" == *"darkmode"* ]] || [[ "${colorlist[$i]}" == *"transparent"* ]] || [[ "${colorlist[$i]}" == *"palette"* ]]; then
      continue
    fi
    # Escape the $ in the color name for sed
    color_name="${colorlist[$i]//$/\\$}"
    sed -i "s/${color_name}/${colorvalues[$i]#\\#}/g" "$STATE_DIR/user/generated/foot/foot.ini"
  done
  
  # Convert term_alpha percentage to decimal for foot (e.g., 70 -> 0.7)
  foot_alpha=$(echo "scale=2; $term_alpha / 100" | bc)
  # Use line number replacement to avoid sed pattern issues
  sed -i "/^alpha=/c\\alpha=$foot_alpha" "$STATE_DIR/user/generated/foot/foot.ini"
  
  # Copy to actual config location
  mkdir -p "$XDG_CONFIG_HOME/foot"
  cp "$STATE_DIR/user/generated/foot/foot.ini" "$XDG_CONFIG_HOME/foot/foot.ini"
}

# Check if terminal theming is enabled in config
CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
if [ -f "$CONFIG_FILE" ]; then
  enable_terminal=$(jq -r '.appearance.wallpaperTheming.enableTerminal' "$CONFIG_FILE")
  if [ "$enable_terminal" = "true" ]; then
    apply_term &
    apply_foot &
  fi
else
  echo "Config file not found at $CONFIG_FILE. Applying terminal theming by default."
  apply_term &
  apply_foot &
fi

# apply_qt & # Qt theming is already handled by kde-material-colors
