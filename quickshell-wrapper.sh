#!/usr/bin/env bash

# Simple wait for Hyprland to be ready
echo "Checking Hyprland readiness..."
if hyprctl monitors >/dev/null 2>&1; then
    echo "Hyprland is ready"
else
    echo "Waiting for Hyprland..."
    sleep 2
fi

# Wait for PipeWire to be fully ready
echo "Checking PipeWire readiness..."
wait_for_pipewire() {
    local max_attempts=10
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if pactl get-default-sink >/dev/null 2>&1 && [ "$(pactl list short sinks | wc -l)" -gt 0 ]; then
            echo "PipeWire audio ready"
            return 0
        fi
        echo "Waiting for PipeWire... (attempt $((attempt + 1))/$max_attempts)"
        sleep 1
        ((attempt++))
    done
    
    echo "Warning: PipeWire not fully ready, starting anyway"
    return 1
}

wait_for_pipewire

# Set icon theme paths and Qt6 theming
export XDG_DATA_DIRS="$HOME/.nix-profile/share:/usr/local/share:/usr/share:$XDG_DATA_DIRS"
export QT_QPA_PLATFORMTHEME="qt6ct"
export QT_ICON_THEME="Adwaita"

# Ensure qt6ct can find the configuration
export QT6CT_CONFIG_PATH="$HOME/.config/qt6ct/qt6ct.conf"

# Set comprehensive QML import paths for all Qt6 modules
QT6_QML_PATHS=""
for path in /nix/store/*qt*6*/lib/qt-6/qml; do
    if [[ -d "$path" ]]; then
        QT6_QML_PATHS="$path:$QT6_QML_PATHS"
    fi
done

export QML2_IMPORT_PATH="$QT6_QML_PATHS:$QML2_IMPORT_PATH"
export QML_IMPORT_PATH="$QML2_IMPORT_PATH"

echo "All services ready, starting quickshell..."
echo "QML import paths configured"

# Run quickshell with the environment set
exec quickshell "$@"
