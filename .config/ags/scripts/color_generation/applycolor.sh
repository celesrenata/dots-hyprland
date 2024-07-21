#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_DIR="$XDG_CONFIG_HOME/ags"
CACHE_DIR="$XDG_CACHE_HOME/ags"
STATE_DIR="$XDG_STATE_HOME/ags"

# sleep 0 # idk i wanted some delay or colors dont get applied properly
if [ ! -d "$CACHE_DIR"/user/generated ]; then
    mkdir -p "$CACHE_DIR"/user/generated
fi
if [ ! -f "$CACHE_DIR"/user/generated/terminal/transparency ]; then
    term_alpha=100 #Set this to < 100 make all your terminals transparent
    echo "$term_alpha" > "$CACHE_DIR"/user/generated/terminal/transparency
else
    term_alpha=$(cat "$CACHE_dir"/user/generated/terminal/transparency)
fi
cd "$CONFIG_DIR" || exit

colornames=''
colorstrings=''
colorlist=()
colorvalues=()

transparentize() {
  local hex="$1"
  local alpha="$2"
  local red green blue

  red=$((16#${hex:1:2}))
  green=$((16#${hex:3:2}))
  blue=$((16#${hex:5:2}))

  printf 'rgba(%d, %d, %d, %.2f)\n' "$red" "$green" "$blue" "$alpha"
}

dehex() {
  local hex="$1"
  local red green blue

  red=$((16#${hex:1:2}))
  green=$((16#${hex:3:2}))
  blue=$((16#${hex:5:2}))

  printf '%d, %d, %d' "$red" "$green" "$blue"
}

get_light_dark() {
    lightdark=""
    if [ ! -f "$STATE_DIR/user/colormode.txt" ]; then
        echo "" > "$STATE_DIR/user/colormode.txt"
    else
        lightdark=$(sed -n '1p' "$STATE_DIR/user/colormode.txt")
    fi
    echo "$lightdark"
}

get_transparency() {
    transparency=""
    if [ ! -f "$CACHE_DIR"/user/colormode.txt ]; then
       echo "" > "$CACHE_DIR"/user/colormode.txt
    else
        transparency=$(sed -n '2p' "$HOME/.cache/ags/user/colormode.txt")
    fi  
    if [ "${transparency}" == "opaque" ]; then
       term_alpha=100
    fi
    echo "$term_alpha"
}

apply_fuzzel() {
    # Check if scripts/templates/fuzzel/fuzzel.ini exists
    if [ ! -f "scripts/templates/fuzzel/fuzzel.ini" ]; then
        echo "Template file not found for Fuzzel. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$CACHE_DIR"/user/generated/fuzzel
    cp "scripts/templates/fuzzel/fuzzel.ini" "$CACHE_DIR"/user/generated/fuzzel/fuzzel.ini
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/fuzzel/fuzzel.ini
    done

    cp  "$CACHE_DIR"/user/generated/fuzzel/fuzzel.ini "$XDG_CONFIG_HOME"/fuzzel/fuzzel.ini
}

apply_foot() {
    if [ ! -f "scripts/templates/foot/foot.ini" ]; then
        echo "Template file not found for Foot. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$CACHE_DIR"/user/generated/foot
    cp "scripts/templates/foot/foot.ini" "$CACHE_DIR"/user/generated/foot/foot.ini
    chmod +w "$CACHE_DIR"/user/generated/foot/foot.ini
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/foot/foot.ini
    done

    cp "$CACHE_DIR"/user/generated/foot/foot.ini "$XDG_CONFIG_HOME"/foot/foot.ini
}

apply_term() {
    term_alpha=$(get_transparency)
    # Check if terminal escape sequence template exists
    if [ ! -f "scripts/templates/terminal/sequences.txt" ]; then
        echo "Template file not found for Terminal. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$CACHE_DIR"/user/generated/terminal
    cp "scripts/templates/terminal/sequences.txt" "$CACHE_DIR"/user/generated/terminal/sequences.txt
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/terminal/sequences.txt
    done

    sed -i "s/\$alpha/$term_alpha/g" "$CACHE_DIR/user/generated/terminal/sequences.txt"

    for file in /dev/pts/*; do
      if [[ $file =~ ^/dev/pts/[0-9]+$ ]]; then
        cat "$CACHE_DIR"/user/generated/terminal/sequences.txt > "$file"
      fi
    done
}

apply_hyprland() {
    # Check if scripts/templates/hypr/hyprland/colors.conf exists
    if [ ! -f "scripts/templates/hypr/hyprland/colors.conf" ]; then
        echo "Template file not found for Hyprland colors. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$CACHE_DIR"/user/generated/hypr/hyprland
    cp "scripts/templates/hypr/hyprland/colors.conf" "$CACHE_DIR"/user/generated/hypr/hyprland/colors.conf
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/hypr/hyprland/colors.conf
    done

    cp "$CACHE_DIR"/user/generated/hypr/hyprland/colors.conf "$XDG_CONFIG_HOME"/hypr/hyprland/colors.conf
}

apply_hyprlock() {
    wallpath=$(swww query | head -1 | awk -F 'image: ' '{print $2}')
    wallpath_png="$HOME"'/.cache/ags/user/generated/hypr/lockscreen.png'
    convert "$wallpath" "$wallpath_png"
    wallpath_png=$(echo "$wallpath_png")
    # Check if scripts/templates/hypr/hyprlock.conf exists
    if [ ! -f "scripts/templates/hypr/hyprlock.conf" ]; then
        echo "Template file not found for hyprlock. Skipping that."
        return
    fi
    # Copy template
    mkdir -p "$CACHE_DIR"/user/generated/hypr/
    cp "scripts/templates/hypr/hyprlock.conf" "$CACHE_DIR"/user/generated/hypr/hyprlock.conf
    # Apply colors
    sed -i "s/{{ SWWW_WALL }}/${wallpath_png}/g" "$CACHE_DIR"/user/generated/hypr/hyprlock.conf
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$CACHE_DIR"/user/generated/hypr/hyprlock.conf
    done

    cp "$CACHE_DIR"/user/generated/hypr/hyprlock.conf "$XDG_CONFIG_HOME"/hypr/hyprlock.conf
}

apply_gtk() { # Using gradience-cli
    lightdark=$(get_light_dark)

    # Copy template
    mkdir -p "$CACHE_DIR"/user/generated/gradience
    cp "scripts/templates/gradience/preset.json" "$CACHE_DIR"/user/generated/gradience/preset.json

    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]}/g" "$CACHE_DIR"/user/generated/gradience/preset.json
    done

    mkdir -p "$XDG_CONFIG_HOME/presets" # create gradience presets folder
    gradience-cli apply -p "$CACHE_DIR"/user/generated/gradience/preset.json --gtk both

    # Set light/dark preference
    # And set GTK theme manually as Gradience defaults to light adw-gtk3
    # (which is unreadable when broken when you use dark mode)
    if [ "$lightdark" = "light" ]; then
        gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    else
        gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    fi
}

apply_wofi() {
    # Check if scripts/templates/wofi/style.css exists
    if [ ! -f "scripts/templates/wofi/style.css" ]; then
        echo "Template file not found for Wofi colors. Skipping that."
        return
    fi
    # Copy template
    cp "scripts/templates/wofi/style.css" "$XDG_CONFIG_HOME"/wofi/style_new.css
    chmod +w "$XDG_CONFIG_HOME"/.config/wofi/style_new.css
    # Apply colors
    for i in "${!colorlist[@]}"; do
        sed -i "s/{{ ${colorlist[$i]} }}/${colorvalues[$i]#\#}/g" "$XDG_CONFIG_HOME"/wofi/style_new.css
    done

    for i in "${!colorlist[@]}"; do
        dehexed=$(dehex ${colorvalues[$i]})
        sed -i "s/{{ ${colorlist[$i]}-rgb }}/${dehexed}/g" "$XDG_CONFIG_HOME"/.config/wofi/style_new.css
    done

    mv "$XDG_CONFIG_HOME/wofi/style_new.css" "$XDG_CONFIG_HOME/wofi/style.css"
}


apply_ags() {
    ags run-js "handleStyles(false);"
    ags run-js 'openColorScheme.value = true; Utils.timeout(2000, () => openColorScheme.value = false);'
}

if [[ "$1" = "--bad-apple" ]]; then
    lightdark=$(get_light_dark)
    cp scripts/color_generation/specials/_material_badapple"${lightdark}".scss $STATE_DIR/scss/_material.scss
    colornames=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f1)
    colorstrings=$(cat scripts/color_generation/specials/_material_badapple"${lightdark}".scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
    IFS=$'\n'
    colorlist=( $colornames ) # Array of color names
    colorvalues=( $colorstrings ) # Array of color values
else
    colornames=$(cat $STATE_DIR/scss/_material.scss | cut -d: -f1)
    colorstrings=$(cat $STATE_DIR/scss/_material.scss | cut -d: -f2 | cut -d ' ' -f2 | cut -d ";" -f1)
    IFS=$'\n'
    colorlist=( $colornames ) # Array of color names
    colorvalues=( $colorstrings ) # Array of color values
fi

if [ "$1" = "term" ]; then
    apply_term &
    exit 0
fi

apply_ags &
apply_hyprland &
apply_hyprlock &
apply_gtk &
apply_fuzzel &
apply_term &
apply_wofi &
apply_foot &
