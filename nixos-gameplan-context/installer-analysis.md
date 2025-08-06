# Installer Analysis: Complete Breakdown

## Overview
After thorough analysis of the original `install.sh` from end-4/dots-hyprland, we now understand exactly what needs to be replicated in NixOS. The installer follows a clear 5-step process that we can map directly to NixOS patterns.

## Key Discovery: FHS Not Needed
Our FHS environment experiment proved that quickshell and all components work fine in standard NixOS environment. The real missing piece is the **Python virtual environment setup** that the installer creates.

## Complete Installer Workflow

### 1. Package Installation (Meta-packages)

The installer installs packages through meta-packages (PKGBUILD files):

#### illogical-impulse-basic
```bash
depends=(
    axel bc coreutils cliphist cmake curl rsync wget ripgrep jq meson xdg-user-dirs
)
```

#### illogical-impulse-widgets  
```bash
depends=(
    fuzzel glib2 hypridle hyprutils hyprlock hyprpicker nm-connection-editor 
    quickshell-git translate-shell wlogout
)
```

#### illogical-impulse-hyprland
```bash
depends=(
    hypridle hyprcursor hyprland hyprland-qtutils hyprland-qt-support hyprlang 
    hyprlock hyprpicker hyprsunset hyprutils hyprwayland-scanner 
    xdg-desktop-portal-hyprland wl-clipboard
)
```

#### illogical-impulse-python
```bash
depends=(
    clang uv gtk4 libadwaita libsoup3 libportal-gtk4 gobject-introspection 
    sassc python-opencv
)
```

### 2. Python Virtual Environment Setup (CRITICAL)

```bash
install-python-packages() {
    UV_NO_MODIFY_PATH=1
    ILLOGICAL_IMPULSE_VIRTUAL_ENV=$XDG_STATE_HOME/quickshell/.venv
    mkdir -p $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)
    
    # Requires Python 3.12 specifically
    uv venv --prompt .venv $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV) -p 3.12
    source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate
    uv pip install -r scriptdata/requirements.txt
    deactivate
}
```

#### Python Requirements (scriptdata/requirements.txt)
```
build==1.2.2.post1
cffi==1.17.1
libsass==0.23.0
material-color-utilities==0.2.1
materialyoucolor==2.0.10
numpy==2.2.2
packaging==24.2
pillow==11.1.0
psutil==6.1.1
pycparser==2.22
pyproject-hooks==1.2.0
pywayland==0.4.18
setproctitle==1.3.4
setuptools==80.9.0
setuptools-scm==8.1.0
wheel==0.45.1
```

### 3. Configuration Copying

Simple rsync operations, no special generation:

```bash
# Copy all .config/* except fish and hypr
for i in $(find .config/ -mindepth 1 -maxdepth 1 ! -name 'fish' ! -name 'hypr' -exec basename {} \;); do
    if [ -d ".config/$i" ]; then 
        rsync -av --delete ".config/$i/" "$XDG_CONFIG_HOME/$i/"
    elif [ -f ".config/$i" ]; then 
        rsync -av ".config/$i" "$XDG_CONFIG_HOME/$i"
    fi
done

# Special handling for hypr (excludes custom/, hyprlock.conf, etc.)
rsync -av --delete --exclude '/custom' --exclude '/hyprlock.conf' --exclude '/hypridle.conf' --exclude '/hyprland.conf' .config/hypr/ "$XDG_CONFIG_HOME"/hypr/
```

### 4. Environment Variables Setup

Critical environment variable set in `.config/hypr/hyprland/env.conf`:

```bash
env = ILLOGICAL_IMPULSE_VIRTUAL_ENV, ~/.local/state/quickshell/.venv
```

This is used by Python scripts throughout the configuration:
- `.config/quickshell/ii/scripts/colors/generate_colors_material.py`
- `.config/quickshell/ii/scripts/colors/switchwall.sh`
- `.config/quickshell/ii/scripts/hyprland/get_keybinds.py`
- `.config/quickshell/ii/scripts/wayland-idle-inhibitor.py`

### 5. System Configuration

```bash
# User groups
sudo usermod -aG video,i2c,input "$(whoami)"

# System services
systemctl --user enable ydotool --now
sudo systemctl enable bluetooth --now

# Desktop settings
gsettings set org.gnome.desktop.interface font-name 'Rubik 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly
```

## NixOS Implementation Strategy

### 1. Package Management
Map all meta-package dependencies to nixpkgs equivalents. Most are already available.

### 2. Python Environment
Create Python environment with exact requirements using `python3.withPackages` or similar.

### 3. Configuration Management
Use `xdg.configFile` to copy upstream source directly, no modifications needed.

### 4. Environment Variables
Set `ILLOGICAL_IMPULSE_VIRTUAL_ENV` in Home Manager session variables.

### 5. System Integration
Use NixOS modules for user groups, services, and desktop settings.

## Key Insights

1. **No FHS needed** - Standard NixOS environment works fine
2. **Python venv is critical** - Many scripts depend on specific Python packages
3. **Configuration is static** - No generation, just copying upstream files
4. **Environment variable required** - Scripts expect `ILLOGICAL_IMPULSE_VIRTUAL_ENV`
5. **QML issues are secondary** - Likely caused by missing Python dependencies

## Next Steps

1. Create NixOS module that replicates installer exactly
2. Set up Python environment with all required packages
3. Copy clean upstream configuration files
4. Set proper environment variables
5. Test with clean upstream source

This approach should resolve all the QML module issues we encountered, as they're likely side effects of missing Python environment rather than fundamental QML problems.
