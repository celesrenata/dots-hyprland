#!/usr/bin/env bash

# Set QML import paths to include missing Qt modules
export QML2_IMPORT_PATH="/nix/store/b4p9px4l3rsah72pyh95s1j68ik84k9i-qt5compat-6.9.1/lib/qt-6/qml:/nix/store/aapj2h6bj11yg1qadhgn1d76cqawz18a-qtpositioning-6.9.1/lib/qt-6/qml:$QML2_IMPORT_PATH"
export QML_IMPORT_PATH="$QML2_IMPORT_PATH"

# Run quickshell with the environment set
exec quickshell "$@"
