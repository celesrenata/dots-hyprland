#!/bin/bash
# Wrapper script to export ILLOGICAL_IMPULSE_VIRTUAL_ENV for NixOS environment
export ILLOGICAL_IMPULSE_VIRTUAL_ENV="$HOME/.local/state/quickshell/.venv"
exec "$(dirname "$0")/get_keybinds.py"
