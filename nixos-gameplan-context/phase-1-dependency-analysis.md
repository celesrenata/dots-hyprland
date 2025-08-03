# Phase 1: Dependency Analysis & Mapping

## Overview
This phase focuses on analyzing all dependencies from the original dots-hyprland repo and mapping them to NixOS equivalents. Based on the wiki and repo analysis, we need to handle both system packages and custom components.

## Core Dependencies Analysis

### From PKGBUILD Files Analysis

#### Basic Dependencies (`illogical-impulse-basic`)
```nix
# Available in nixpkgs
axel           -> pkgs.axel
bc             -> pkgs.bc  
coreutils      -> pkgs.coreutils
cliphist       -> pkgs.cliphist
cmake          -> pkgs.cmake
curl           -> pkgs.curl
rsync          -> pkgs.rsync
wget           -> pkgs.wget
ripgrep        -> pkgs.ripgrep
jq             -> pkgs.jq
meson          -> pkgs.meson
xdg-user-dirs  -> pkgs.xdg-user-dirs
```

#### Hyprland Ecosystem (`illogical-impulse-hyprland`)
```nix
# Most available in nixpkgs, some in hyprland overlay
hypridle                    -> pkgs.hypridle
hyprcursor                  -> pkgs.hyprcursor
hyprland                    -> pkgs.hyprland
hyprland-qtutils           -> pkgs.hyprland-qtutils
hyprland-qt-support        -> pkgs.hyprland-qt-support
hyprlang                   -> pkgs.hyprlang
hyprlock                   -> pkgs.hyprlock
hyprpicker                 -> pkgs.hyprpicker
hyprsunset                 -> pkgs.hyprsunset
hyprutils                  -> pkgs.hyprutils
hyprwayland-scanner        -> pkgs.hyprwayland-scanner
xdg-desktop-portal-hyprland -> pkgs.xdg-desktop-portal-hyprland
wl-clipboard               -> pkgs.wl-clipboard
```

#### Widget System (`illogical-impulse-widgets`)
```nix
# Mix of available and custom packages needed
fuzzel              -> pkgs.fuzzel
glib2               -> pkgs.glib
hypridle            -> pkgs.hypridle
hyprutils           -> pkgs.hyprutils
hyprlock            -> pkgs.hyprlock
hyprpicker          -> pkgs.hyprpicker
nm-connection-editor -> pkgs.networkmanagerapplet
quickshell-git      -> CUSTOM DERIVATION NEEDED
translate-shell     -> pkgs.translate-shell
wlogout             -> pkgs.wlogout
```

#### Audio System (`illogical-impulse-audio`)
```nix
# Audio dependencies (need to check PKGBUILD)
# Likely includes: pipewire, wireplumber, pavucontrol, etc.
```

#### Fonts & Themes (`illogical-impulse-fonts-themes`)
```nix
# Font and theme packages
# Need to analyze specific fonts and icon themes used
```

### Critical Custom Packages Needed

#### 1. quickshell-git (HIGHEST PRIORITY)
- **Status**: Not in nixpkgs, needs custom derivation
- **Importance**: Critical - entire widget system depends on this
- **Source**: https://github.com/outfoxxed/quickshell
- **Build**: Qt6-based, uses CMake
- **Dependencies**: Qt6, qtdeclarative, qtwayland, etc.

#### 2. Material Color Utilities
- **Status**: Python-based color generation system
- **Location**: `.config/quickshell/ii/scripts/colors/`
- **Dependencies**: Python, matugen, material-color-utilities-python

#### 3. Custom Scripts & Services
- **Location**: `.config/quickshell/ii/scripts/`
- **Types**: Python scripts, shell scripts
- **Functions**: AI integration, color generation, system integration

## NixOS Package Mapping Strategy

### 1. Direct Mappings (Available in nixpkgs)
```nix
# Create a comprehensive package list
basicPackages = with pkgs; [
  # Core utilities
  axel bc coreutils cliphist cmake curl rsync wget ripgrep jq meson xdg-user-dirs
  
  # Hyprland ecosystem  
  hypridle hyprcursor hyprland hyprland-qtutils hyprlang hyprlock
  hyprpicker hyprsunset hyprutils hyprwayland-scanner
  xdg-desktop-portal-hyprland wl-clipboard
  
  # UI components
  fuzzel glib translate-shell wlogout networkmanagerapplet
  
  # Additional tools
  foot kitty # terminals
  matugen # color generation
];
```

### 2. Custom Derivations Needed
```nix
# packages/quickshell/default.nix
{ lib, stdenv, fetchFromGitHub, cmake, qt6, ... }:

stdenv.mkDerivation rec {
  pname = "quickshell";
  version = "unstable-2024-08-02";
  
  src = fetchFromGitHub {
    owner = "outfoxxed";
    repo = "quickshell";
    rev = "main"; # or specific commit
    hash = "sha256-...";
  };
  
  nativeBuildInputs = [ cmake qt6.wrapQtAppsHook ];
  buildInputs = with qt6; [ qtbase qtdeclarative qtwayland ];
  
  # Build configuration
  cmakeFlags = [ ... ];
  
  meta = with lib; {
    description = "A QtQuick based desktop shell toolkit";
    homepage = "https://quickshell.outfoxxed.me/";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
```

### 3. Overlay Strategy
```nix
# overlays/default.nix
final: prev: {
  quickshell = final.callPackage ../packages/quickshell { };
  
  # Other custom packages
  material-color-utilities = final.callPackage ../packages/material-color-utilities { };
}
```

## Configuration File Analysis

### Key Configuration Locations
Based on wiki analysis:

1. **Hyprland Config**: `~/.config/hypr/`
   - Main: `hyprland.conf`
   - Custom: `custom/` (user overrides)
   - Default: `hyprland/` (shipped configs)

2. **Quickshell Config**: `~/.config/quickshell/ii/`
   - Main: `shell.qml`, `settings.qml`
   - Modules: `modules/` (bar, overview, etc.)
   - Services: `services/` (AI, notifications, etc.)
   - Scripts: `scripts/` (color generation, utilities)

3. **Application Configs**: Various in `~/.config/`
   - `foot/`, `kitty/`, `fuzzel/`, etc.

### NixOS Configuration Strategy
```nix
# Use xdg.configFile for configuration management
xdg.configFile = {
  "hypr" = {
    source = ./configs/hypr;
    recursive = true;
  };
  
  "quickshell" = {
    source = ./configs/quickshell;
    recursive = true;
  };
  
  # Individual app configs
  "foot/foot.ini".source = ./configs/foot/foot.ini;
  "kitty/kitty.conf".source = ./configs/kitty/kitty.conf;
  # ... etc
};
```

## Dependencies Not Yet Analyzed

### Need Further Investigation
1. **Audio packages** - from `illogical-impulse-audio` PKGBUILD
2. **Font packages** - from `illogical-impulse-fonts-themes` PKGBUILD  
3. **Python dependencies** - from `scriptdata/requirements.txt`
4. **Theme packages** - icon themes, GTK themes, etc.
5. **Development tools** - for building custom components

### Python Dependencies Analysis
From `scriptdata/requirements.txt`:
```
# Need to check what Python packages are required
# Likely includes: requests, material-color-utilities, etc.
```

## Action Items for Phase 1

### Immediate Tasks
1. **Create quickshell derivation** - highest priority
2. **Map all PKGBUILD dependencies** to nixpkgs equivalents
3. **Analyze Python requirements** and create derivations if needed
4. **Test basic package availability** in current nixpkgs

### Validation Steps
1. **Package availability check**:
   ```bash
   nix-env -qaP | grep -E "(hyprland|quickshell|fuzzel|...)"
   ```

2. **Build test environment**:
   ```nix
   # Test basic package installation
   environment.systemPackages = with pkgs; [
     # All mapped packages
   ];
   ```

3. **Custom package testing**:
   ```bash
   nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/quickshell {}'
   ```

## Expected Outcomes

### Deliverables
1. **Complete package mapping** - Arch packages → NixOS packages
2. **Custom derivations** - For packages not in nixpkgs
3. **Dependency graph** - Understanding of build order and requirements
4. **Package availability report** - What's available vs. what needs custom work

### Success Criteria
- [ ] All core dependencies identified and mapped
- [ ] quickshell derivation created and building
- [ ] Custom packages identified and prioritized
- [ ] Clear understanding of configuration file structure
- [ ] Foundation ready for Phase 2 (NixOS Module Structure)

## Notes from Wiki Analysis

### Key Insights
1. **Quickshell is central** - entire widget system depends on it
2. **Material You theming** - requires color generation scripts
3. **Modular design** - can enable/disable components in shell.qml
4. **Configuration flexibility** - custom/ directory for user overrides
5. **AI integration** - requires API keys and service configuration
6. **Translation support** - multiple language files available

### Potential Challenges
1. **quickshell-git** - bleeding edge, may need frequent updates
2. **Color generation** - complex Python/shell script integration
3. **Service integration** - systemd services, dbus, etc.
4. **Theme consistency** - ensuring all components use same theme
5. **Performance** - Quickshell vs AGS performance considerations
