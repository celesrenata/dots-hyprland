# Phase 3: Core Implementation Strategy

## Overview
This phase focuses on implementing the core functionality of dots-hyprland for NixOS, starting with essential features and building up to the complete system. Based on the wiki analysis, we prioritize the most critical components first.

## Implementation Priority Order

### Priority 1: Foundation (Critical Path)
1. **Quickshell Package** - Custom derivation (blocking everything else)
2. **Basic Hyprland Config** - Window manager setup
3. **Essential Applications** - Terminal, launcher, basic tools
4. **Package Integration** - Ensure all dependencies work

### Priority 2: Core Features (High Impact)
1. **Quickshell Widget System** - Bar, overview, basic widgets
2. **Material You Theming** - Color generation and application
3. **Configuration Management** - Template system and user customization
4. **Service Integration** - Systemd services, autostart

### Priority 3: Advanced Features (Enhancement)
1. **AI Integration** - Gemini/Ollama setup
2. **Advanced Widgets** - Sidebars, notifications, media controls
3. **Customization Options** - Full configuration flexibility
4. **Performance Optimization** - Resource usage, startup time

## Core Implementation Details

### 1. Quickshell Package Implementation

#### Package Structure (`packages/quickshell/default.nix`)
```nix
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
}:

stdenv.mkDerivation rec {
  pname = "quickshell";
  version = "unstable-2024-08-02";

  src = fetchFromGitHub {
    owner = "outfoxxed";
    repo = "quickshell";
    rev = "main"; # Use specific commit hash in production
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = with qt6; [
    qtbase
    qtdeclarative
    qtwayland
    qtsvg
    wayland
    wayland-protocols
    libxkbcommon
    pam
    systemd
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_QT6=ON"
  ];

  meta = with lib; {
    description = "A QtQuick based desktop shell toolkit";
    homepage = "https://quickshell.outfoxxed.me/";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.end4 ]; # Add to nixpkgs maintainers
  };
}
```

#### Build Testing Strategy
```bash
# Test build locally
nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/quickshell {}'

# Test in development shell
nix develop
cmake -B build -S .
make -C build
```

### 2. Basic Hyprland Configuration

#### Configuration Template System
Based on original `.config/hypr/hyprland.conf`:

```nix
# lib/templates.nix
{ lib, pkgs }:

let
  generateHyprlandConfig = { 
    modifier ? "SUPER"
  , terminal ? "foot"
  , animations ? true
  , blur ? false
  , monitors ? []
  , workspaces ? 10
  , customConfig ? ""
  }: ''
    # Generated Hyprland configuration for dots-hyprland
    
    # Monitor configuration
    ${lib.concatMapStringsSep "\n" (m: 
      "monitor = ${m.name},${m.resolution}@${toString m.refreshRate},${m.position},1"
    ) monitors}
    
    # Variables
    $mod = ${modifier}
    $terminal = ${terminal}
    
    # General configuration
    general {
        gaps_in = 4
        gaps_out = 8
        border_size = 2
        col.active_border = $accent
        col.inactive_border = $surface
        layout = dwindle
    }
    
    # Decoration
    decoration {
        rounding = 12
        ${lib.optionalString blur ''
        blur {
            enabled = true
            size = 6
            passes = 3
            new_optimizations = true
        }
        ''}
        drop_shadow = true
        shadow_range = 30
        shadow_render_power = 3
        col.shadow = 0x66000000
    }
    
    # Animations
    ${lib.optionalString animations ''
    animations {
        enabled = true
        bezier = materialEaseInOut,0.4, 0, 0.2, 1
        bezier = materialEaseIn,0.4, 0, 1, 1  
        bezier = materialEaseOut,0, 0, 0.2, 1
        
        animation = windows,1,3,materialEaseInOut,slide
        animation = border,1,10,default
        animation = fade,1,2,materialEaseInOut
        animation = workspaces,1,3,materialEaseInOut,slide
    }
    ''}
    
    # Keybinds
    bind = $mod, Return, exec, $terminal
    bind = $mod, Q, killactive
    bind = $mod, M, exit
    bind = $mod, E, exec, nautilus
    bind = $mod, V, togglefloating
    bind = $mod, slash, exec, quickshell -c cheatsheet
    bind = $mod, Tab, exec, quickshell -c overview
    
    # Workspace binds
    ${lib.concatMapStringsSep "\n" (i: 
      "bind = $mod, ${toString i}, workspace, ${toString i}"
    ) (lib.range 1 workspaces)}
    
    ${lib.concatMapStringsSep "\n" (i: 
      "bind = $mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
    ) (lib.range 1 workspaces)}
    
    # Window rules
    windowrule = float,^(pavucontrol)$
    windowrule = float,^(nm-connection-editor)$
    windowrule = float,^(blueman-manager)$
    windowrule = noblur,.* # Disable blur by default for performance
    
    # Custom configuration
    ${customConfig}
  '';
in
{
  inherit generateHyprlandConfig;
}
```

### 3. Essential Applications Configuration

#### Application Configuration Templates
```nix
# configs/applications/foot.ini.template
[main]
term=xterm-256color
login-shell=yes
app-id=foot
title=foot
locked-title=no

[bell]
urgent=no
notify=no
visual=no
command=
command-focused=no

[scrollback]
lines=1000
multiplier=3.0
indicator-position=relative
indicator-format=""

[url]
launch=xdg-open ${url}
label-letters=sadfjklewcmpgh
osc8-underline=url-mode
protocols=http, https, ftp, ftps, file, gemini, gopher
uri-characters=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.,~:;/?#@!$&%*+="'()[]

[cursor]
style=beam
color=@CURSOR_COLOR@
blink=no
beam-thickness=1.5
underline-thickness=<font-metrics>

[mouse]
hide-when-typing=no
alternate-scroll-mode=yes

[colors]
alpha=0.95
background=@BACKGROUND_COLOR@
foreground=@FOREGROUND_COLOR@

# Material You color palette will be injected here
regular0=@COLOR0@
regular1=@COLOR1@
regular2=@COLOR2@
regular3=@COLOR3@
regular4=@COLOR4@
regular5=@COLOR5@
regular6=@COLOR6@
regular7=@COLOR7@

bright0=@COLOR8@
bright1=@COLOR9@
bright2=@COLOR10@
bright3=@COLOR11@
bright4=@COLOR12@
bright5=@COLOR13@
bright6=@COLOR14@
bright7=@COLOR15@

[csd]
preferred=server
size=26
font=@FONT_FAMILY@
color=@FOREGROUND_COLOR@
hide-when-maximized=no
double-click-to-maximize=yes
border-width=0
border-color=@BORDER_COLOR@
button-width=26
button-color=@BUTTON_COLOR@
button-minimize-color=@BUTTON_MINIMIZE_COLOR@
button-maximize-color=@BUTTON_MAXIMIZE_COLOR@
button-close-color=@BUTTON_CLOSE_COLOR@

[key-bindings]
scrollback-up-page=Shift+Page_Up
scrollback-up-half-page=none
scrollback-up-line=none
scrollback-down-page=Shift+Page_Down
scrollback-down-half-page=none
scrollback-down-line=none
clipboard-copy=Control+Shift+c XF86Copy
clipboard-paste=Control+Shift+v XF86Paste
primary-paste=Shift+Insert
search-start=Control+Shift+r
font-increase=Control+plus Control+equal Control+KP_Add
font-decrease=Control+minus Control+KP_Subtract
font-reset=Control+0 Control+KP_0
spawn-terminal=Control+Shift+n
minimize=none
maximize=none
fullscreen=F11
pipe-visible=[sh -c "xurls | fuzzel | xargs -r firefox"] none
pipe-scrollback=[sh -c "xurls | fuzzel | xargs -r firefox"] none
pipe-selected=[xargs -r firefox] none
show-urls-launch=Control+Shift+u
show-urls-copy=none
show-urls-persistent=none
prompt-prev=Control+Shift+z
prompt-next=Control+Shift+x
unicode-input=Control+Shift+u
noop=none

[search-bindings]
cancel=Control+g Control+c Escape
commit=Return
find-prev=Control+r
find-next=Control+s
cursor-left=Left Control+b
cursor-left-word=Control+Left Mod1+b
cursor-right=Right Control+f
cursor-right-word=Control+Right Mod1+f
cursor-home=Home Control+a
cursor-end=End Control+e
delete-prev=BackSpace
delete-prev-word=Mod1+BackSpace Control+BackSpace
delete-next=Delete
delete-next-word=Mod1+d Control+Delete
extend-to-word-boundary=Control+w
extend-to-next-whitespace=Control+Shift+w
clipboard-paste=Control+v Control+Shift+v Control+y XF86Paste
primary-paste=Shift+Insert
unicode-input=none

[mouse-bindings]
selection-override-modifiers=Shift
primary-paste=BTN_MIDDLE
select-begin=BTN_LEFT
select-begin-block=Control+BTN_LEFT
select-extend=BTN_RIGHT
select-extend-character-wise=Control+BTN_RIGHT
select-word=BTN_LEFT-2
select-word-whitespace=Control+BTN_LEFT-2
select-row=BTN_LEFT-3
```

### 4. Color Generation System

#### Material You Color Integration
Based on `.config/quickshell/ii/scripts/colors/`:

```nix
# packages/material-color-utilities/default.nix
{ lib
, python3Packages
, fetchPypi
}:

python3Packages.buildPythonApplication rec {
  pname = "material-color-utilities";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  propagatedBuildInputs = with python3Packages; [
    pillow
    numpy
  ];

  meta = with lib; {
    description = "Material Design color utilities";
    homepage = "https://github.com/material-foundation/material-color-utilities-python";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
```

#### Color Generation Script
```nix
# lib/colors.nix
{ lib, pkgs }:

let
  generateMaterialColors = wallpaper: pkgs.writeShellScript "generate-colors" ''
    #!/usr/bin/env bash
    
    # Generate Material You colors from wallpaper
    WALLPAPER="${wallpaper}"
    CACHE_DIR="$HOME/.cache/dots-hyprland/colors"
    
    mkdir -p "$CACHE_DIR"
    
    # Use matugen to generate colors
    ${pkgs.matugen}/bin/matugen image "$WALLPAPER" \
      --mode dark \
      --type scheme-content \
      --contrast 0.0 \
      --json > "$CACHE_DIR/colors.json"
    
    # Extract colors for different applications
    ${pkgs.jq}/bin/jq -r '.colors.dark' "$CACHE_DIR/colors.json" > "$CACHE_DIR/dark.json"
    ${pkgs.jq}/bin/jq -r '.colors.light' "$CACHE_DIR/colors.json" > "$CACHE_DIR/light.json"
    
    # Generate application-specific color files
    python3 ${./color-processor.py} "$CACHE_DIR"
  '';

  applyColorsToTemplate = template: colors: 
    lib.replaceStrings 
      (lib.attrNames colors)
      (lib.attrValues colors)
      template;
in
{
  inherit generateMaterialColors applyColorsToTemplate;
}
```

### 5. Service Integration

#### Systemd User Services
```nix
# modules/components/services.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.services;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.services = {
    enable = mkEnableOption "dots-hyprland system services";
    
    autostart = mkEnableOption "Autostart services with Hyprland" // { default = true; };
  };

  config = mkIf cfg.enable {
    # Quickshell service
    systemd.user.services.quickshell = mkIf mainCfg.components.quickshell {
      Unit = {
        Description = "Quickshell - QtQuick based desktop shell";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
        Requisite = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/quickshell";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };

      Install = mkIf cfg.autostart {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Color generation service
    systemd.user.services.material-colors = mkIf mainCfg.components.theming {
      Unit = {
        Description = "Material You color generation";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "generate-material-colors" ''
          ${lib.getExe pkgs.matugen} image "${mainCfg.theming.wallpaper}" \
            --mode ${mainCfg.theming.colorScheme} \
            --json > "$HOME/.cache/dots-hyprland/colors.json"
          
          # Reload Quickshell to apply new colors
          ${pkgs.systemd}/bin/systemctl --user reload-or-restart quickshell.service
        '';
        RemainAfterExit = true;
      };

      Install = mkIf cfg.autostart {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Hypridle service
    systemd.user.services.hypridle = mkIf mainCfg.components.hyprland {
      Unit = {
        Description = "Hyprland idle daemon";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = mkIf cfg.autostart {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Create hyprland session target
    systemd.user.targets.hyprland-session = {
      Unit = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
```

## Implementation Testing Strategy

### 1. Component Testing
```bash
# Test individual components
nix build .#packages.x86_64-linux.quickshell
nix build .#homeConfigurations.test.activationPackage

# Test in VM
nixos-rebuild build-vm --flake .#test-vm
```

### 2. Integration Testing
```nix
# Test configuration in development
{
  programs.dots-hyprland = {
    enable = true;
    style = "illogical-impulse";
    
    # Enable only core components for testing
    components = {
      hyprland = true;
      quickshell = true;
      theming = false; # Disable initially
      ai = false;
    };
    
    # Minimal feature set
    features = {
      overview = true;
      sidebar = false;
      notifications = true;
      mediaControls = false;
    };
  };
}
```

### 3. Validation Checklist
- [ ] Quickshell package builds successfully
- [ ] Hyprland starts with generated configuration
- [ ] Basic widgets (bar, overview) function
- [ ] Keybinds work as expected
- [ ] Services start automatically
- [ ] Configuration templates generate correctly
- [ ] No critical errors in logs

## Action Items for Phase 3

### Week 1: Foundation
1. **Create quickshell derivation** and test build
2. **Implement basic Hyprland config** generation
3. **Set up essential applications** (foot, fuzzel)
4. **Test basic integration** in VM

### Week 2: Core Features  
1. **Implement Quickshell widget system** integration
2. **Create configuration template system**
3. **Add systemd service management**
4. **Test complete core functionality**

### Week 3: Polish & Testing
1. **Add Material You color generation**
2. **Implement user customization options**
3. **Comprehensive testing and debugging**
4. **Documentation and examples**

## Expected Outcomes

### Deliverables
1. **Working quickshell package** - builds and runs
2. **Functional Hyprland setup** - complete window manager config
3. **Basic widget system** - bar, overview, essential widgets
4. **Service integration** - proper systemd service management
5. **Configuration system** - template-based, customizable
6. **Testing framework** - VM testing, validation scripts

### Success Criteria
- [ ] Complete desktop environment boots and functions
- [ ] All core widgets operational
- [ ] Keybinds work as documented
- [ ] Services start/stop correctly
- [ ] Configuration changes apply properly
- [ ] Performance acceptable (startup < 10s)
- [ ] No critical bugs or crashes
- [ ] Ready for Phase 4 (Advanced Features)

## Risk Mitigation

### Potential Issues
1. **Quickshell build failures** - Complex Qt6 dependencies
2. **Service timing issues** - Race conditions on startup
3. **Configuration conflicts** - Template generation errors
4. **Performance problems** - Resource usage, memory leaks

### Mitigation Strategies
1. **Incremental testing** - Test each component individually
2. **Fallback configurations** - Minimal working setups
3. **Comprehensive logging** - Debug service issues
4. **Performance monitoring** - Resource usage tracking
