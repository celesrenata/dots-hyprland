{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, wayland
, wayland-protocols
, libxkbcommon
, pam
, systemd
, quickshell
}:

# Extended quickshell package with additional Qt modules required for end-4 configuration
quickshell.overrideAttrs (oldAttrs: {
  pname = "quickshell-extended";
  
  buildInputs = oldAttrs.buildInputs ++ (with qt6; [
    # Additional Qt modules required by end-4 configuration
    qt5compat  # Provides Qt5Compat.GraphicalEffects
    qtgraphicaleffects  # Additional graphical effects
    qtquickcontrols2  # Enhanced controls
    qtmultimedia  # Media support
  ]);

  # Ensure Qt modules are available at runtime
  qtWrapperArgs = [
    "--prefix QML2_IMPORT_PATH : ${qt6.qt5compat}/${qt6.qtbase.qtQmlPrefix}"
    "--prefix QML2_IMPORT_PATH : ${qt6.qtgraphicaleffects}/${qt6.qtbase.qtQmlPrefix}"
    "--prefix QML2_IMPORT_PATH : ${qt6.qtquickcontrols2}/${qt6.qtbase.qtQmlPrefix}"
    "--prefix QML2_IMPORT_PATH : ${qt6.qtmultimedia}/${qt6.qtbase.qtQmlPrefix}"
  ];

  meta = oldAttrs.meta // {
    description = "Extended Quickshell with additional Qt modules for end-4 dots-hyprland";
  };
})
