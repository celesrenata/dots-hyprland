# Phase 1: Complete Dependency Mapping

## Overview
This document maps all dependencies from the original dots-hyprland Arch packages to their NixOS equivalents.

## Package Categories Analysis

### 1. Basic Dependencies (`illogical-impulse-basic`)
```nix
# All available in nixpkgs
basicPackages = with pkgs; [
  axel           # ✅ pkgs.axel
  bc             # ✅ pkgs.bc  
  coreutils      # ✅ pkgs.coreutils
  cliphist       # ✅ pkgs.cliphist
  cmake          # ✅ pkgs.cmake
  curl           # ✅ pkgs.curl
  rsync          # ✅ pkgs.rsync
  wget           # ✅ pkgs.wget
  ripgrep        # ✅ pkgs.ripgrep
  jq             # ✅ pkgs.jq
  meson          # ✅ pkgs.meson
  xdg-user-dirs  # ✅ pkgs.xdg-user-dirs
];
```

### 2. Hyprland Ecosystem (`illogical-impulse-hyprland`)
```nix
# Most available in nixpkgs
hyprlandPackages = with pkgs; [
  hypridle                    # ✅ pkgs.hypridle
  hyprcursor                  # ✅ pkgs.hyprcursor
  hyprland                    # ✅ pkgs.hyprland
  hyprland-qtutils           # ✅ pkgs.hyprland-qtutils
  hyprland-qt-support        # ❓ Check if available
  hyprlang                   # ✅ pkgs.hyprlang
  hyprlock                   # ✅ pkgs.hyprlock
  hyprpicker                 # ✅ pkgs.hyprpicker
  hyprsunset                 # ✅ pkgs.hyprsunset
  hyprutils                  # ✅ pkgs.hyprutils
  hyprwayland-scanner        # ✅ pkgs.hyprwayland-scanner
  xdg-desktop-portal-hyprland # ✅ pkgs.xdg-desktop-portal-hyprland
  wl-clipboard               # ✅ pkgs.wl-clipboard
];
```

### 3. Widget System (`illogical-impulse-widgets`)
```nix
# Mix of available and custom packages needed
widgetPackages = with pkgs; [
  fuzzel              # ✅ pkgs.fuzzel
  glib                # ✅ pkgs.glib (glib2 in Arch)
  hypridle            # ✅ pkgs.hypridle
  hyprutils           # ✅ pkgs.hyprutils
  hyprlock            # ✅ pkgs.hyprlock
  hyprpicker          # ✅ pkgs.hyprpicker
  networkmanagerapplet # ✅ pkgs.networkmanagerapplet (nm-connection-editor)
  # quickshell-git    # ❌ CUSTOM DERIVATION NEEDED
  translate-shell     # ✅ pkgs.translate-shell
  wlogout             # ✅ pkgs.wlogout
];
```

### 4. Audio System (`illogical-impulse-audio`)
```nix
audioPackages = with pkgs; [
  cava                # ✅ pkgs.cava
  pavucontrol-qt      # ✅ pkgs.pavucontrol-qt
  wireplumber         # ✅ pkgs.wireplumber
  libdbusmenu-gtk3    # ✅ pkgs.libdbusmenu-gtk3
  playerctl           # ✅ pkgs.playerctl
];
```

### 5. Fonts & Themes (`illogical-impulse-fonts-themes`)
```nix
fontsThemesPackages = with pkgs; [
  # Themes
  # adw-gtk-theme-git        # ❓ Check adwaita-gtk-theme
  breeze-gtk               # ✅ pkgs.libsForQt5.breeze-gtk
  # breeze-plus              # ❓ Custom theme
  # darkly-bin               # ❓ Custom theme
  
  # Tools
  eza                      # ✅ pkgs.eza
  fish                     # ✅ pkgs.fish
  fontconfig               # ✅ pkgs.fontconfig
  # kde-material-you-colors  # ❌ CUSTOM DERIVATION NEEDED
  kitty                    # ✅ pkgs.kitty
  # matugen-bin              # ✅ pkgs.matugen
  starship                 # ✅ pkgs.starship
  
  # Fonts
  # otf-space-grotesk        # ❓ Check font availability
  jetbrains-mono           # ✅ pkgs.jetbrains-mono
  # ttf-gabarito-git         # ❓ Custom font
  # ttf-material-symbols-variable-git # ❓ Custom font
  # ttf-readex-pro           # ❓ Custom font
  # ttf-rubik-vf             # ❓ Custom font
  twemoji-color-font       # ✅ pkgs.twemoji-color-font
];
```

### 6. Python Dependencies (`illogical-impulse-python`)
```nix
pythonPackages = with pkgs; [
  clang               # ✅ pkgs.clang
  # uv                # ✅ pkgs.uv (Python package manager)
  gtk4                # ✅ pkgs.gtk4
  libadwaita          # ✅ pkgs.libadwaita
  libsoup_3           # ✅ pkgs.libsoup_3
  libportal-gtk4      # ✅ pkgs.libportal-gtk4
  gobject-introspection # ✅ pkgs.gobject-introspection
  sassc               # ✅ pkgs.sassc
  opencv4             # ✅ pkgs.opencv4 (python-opencv)
];
```

### 7. Screen Capture (`illogical-impulse-screencapture`)
```nix
screencapturePackages = with pkgs; [
  # hyprshot           # ❓ Check availability
  slurp               # ✅ pkgs.slurp
  swappy              # ✅ pkgs.swappy
  tesseract           # ✅ pkgs.tesseract
  # tesseract-data-eng # ✅ pkgs.tesseract (includes English data)
  wf-recorder         # ✅ pkgs.wf-recorder
];
```

### 8. Toolkit (`illogical-impulse-toolkit`)
```nix
toolkitPackages = with pkgs; [
  kdialog             # ✅ pkgs.kdialog
  qt6.qt5compat       # ✅ pkgs.qt6.qt5compat
  # qt6-avif-image-plugin # ❓ Check Qt6 plugins
  qt6.qtbase          # ✅ pkgs.qt6.qtbase
  qt6.qtdeclarative   # ✅ pkgs.qt6.qtdeclarative
  qt6.qtimageformats  # ✅ pkgs.qt6.qtimageformats
  qt6.qtmultimedia    # ✅ pkgs.qt6.qtmultimedia
  qt6.qtpositioning   # ✅ pkgs.qt6.qtpositioning
  # qt6-quicktimeline # ❓ Check availability
  qt6.qtsensors       # ✅ pkgs.qt6.qtsensors
  qt6.qtsvg           # ✅ pkgs.qt6.qtsvg
  qt6.qttools         # ✅ pkgs.qt6.qttools
  qt6.qttranslations  # ✅ pkgs.qt6.qttranslations
  qt6.qtvirtualkeyboard # ✅ pkgs.qt6.qtvirtualkeyboard
  qt6.qtwayland       # ✅ pkgs.qt6.qtwayland
  # syntax-highlighting # ✅ pkgs.kdePackages.syntax-highlighting
  upower              # ✅ pkgs.upower
  wtype               # ✅ pkgs.wtype
  ydotool             # ✅ pkgs.ydotool
];
```

### 9. Python Requirements (from requirements.txt)
```nix
pythonRequirements = with python3Packages; [
  build                    # ✅ python3Packages.build
  pillow                   # ✅ python3Packages.pillow
  setuptools-scm           # ✅ python3Packages.setuptools-scm
  wheel                    # ✅ python3Packages.wheel
  # pywayland              # ✅ python3Packages.pywayland
  psutil                   # ✅ python3Packages.psutil
  # materialyoucolor       # ❓ Check availability
  # libsass                # ✅ python3Packages.libsass
  material-color-utilities # ❓ Check availability
  # setproctitle           # ✅ python3Packages.setproctitle
];
```

## Critical Custom Packages Needed

### 1. quickshell-git (HIGHEST PRIORITY)
- **Status**: ❌ Not in nixpkgs
- **Importance**: CRITICAL - entire widget system depends on this
- **Source**: https://github.com/outfoxxed/quickshell
- **Build**: Qt6-based, uses CMake
- **Action**: Create custom derivation immediately

### 2. Material Color Utilities
- **Status**: ❓ Need to check if material-color-utilities is in nixpkgs
- **Importance**: HIGH - needed for Material You theming
- **Action**: Check nixpkgs, create derivation if needed

### 3. kde-material-you-colors
- **Status**: ❌ Not in nixpkgs (Arch AUR package)
- **Importance**: MEDIUM - KDE theming integration
- **Action**: Create custom derivation or find alternative

### 4. matugen
- **Status**: ✅ Available as pkgs.matugen
- **Importance**: HIGH - color generation from wallpaper
- **Action**: Use existing package

## Package Availability Check Results

### ✅ Available in nixpkgs (confirmed)
- All basic dependencies
- Most Hyprland ecosystem packages
- Most audio packages
- Most toolkit packages
- Core Python packages

### ❓ Need to verify availability
- hyprland-qt-support
- Qt6 plugins (avif, quicktimeline)
- Custom fonts (gabarito, material-symbols, etc.)
- Python packages (materialyoucolor, material-color-utilities)
- hyprshot

### ❌ Definitely need custom derivations
- quickshell-git (CRITICAL)
- kde-material-you-colors
- Custom themes (breeze-plus, darkly-bin)
- Custom fonts (ttf-gabarito-git, etc.)

## Next Steps

1. **Verify package availability** - Check nixpkgs for questionable packages
2. **Create quickshell derivation** - Highest priority blocking package
3. **Test basic package installation** - Ensure all confirmed packages work
4. **Create missing derivations** - For packages not in nixpkgs
5. **Document alternatives** - For packages that can't be easily ported
