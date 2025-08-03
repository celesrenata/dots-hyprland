{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.hyprland;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.hyprland = {
    enable = mkEnableOption "Hyprland configuration for dots-hyprland";

    animations = mkEnableOption "Hyprland animations" // { default = true; };
    blur = mkEnableOption "Window blur effects" // { default = true; };
    
    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor name";
            example = "DP-1";
          };
          resolution = mkOption {
            type = types.str;
            default = "preferred";
            description = "Monitor resolution";
            example = "1920x1080";
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
            description = "Monitor refresh rate";
          };
          position = mkOption {
            type = types.str;
            default = "auto";
            description = "Monitor position";
            example = "0x0";
          };
        };
      });
      default = [];
      description = "Monitor configuration";
    };

    workspaces = mkOption {
      type = types.int;
      default = 10;
      description = "Number of workspaces";
    };

    terminal = mkOption {
      type = types.str;
      default = "foot";
      description = "Default terminal emulator";
    };

    customConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Hyprland configuration";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      
      # Use extraConfig for now to avoid Home Manager option conflicts
      extraConfig = ''
        # Variables
        $mod = SUPER
        $terminal = ${cfg.terminal}
        
        # Monitor configuration
        ${if cfg.monitors != [] then
          lib.concatMapStringsSep "\n" (m: "monitor = ${m.name},${m.resolution}@${toString m.refreshRate},${m.position},1") cfg.monitors
        else
          "monitor = ,preferred,auto,1"
        }
        
        # General settings
        general {
            gaps_in = 4
            gaps_out = 8
            border_size = 2
            col.active_border = rgba(bb9af7ff)
            col.inactive_border = rgba(414868ff)
            layout = dwindle
            allow_tearing = false
        }
        
        # Decoration
        decoration {
            rounding = 12
            
            ${lib.optionalString cfg.blur ''
            blur {
                enabled = true
                size = 6
                passes = 3
                new_optimizations = true
                xray = false
                ignore_opacity = false
            }
            ''}
            
            shadow {
                enabled = true
                range = 30
                render_power = 3
                color = 0x66000000
            }
            
            dim_inactive = false
            dim_strength = 0.1
        }
        
        # Animations
        ${lib.optionalString cfg.animations ''
        animations {
            enabled = true
            
            bezier = materialEaseInOut,0.4, 0, 0.2, 1
            bezier = materialEaseIn,0.4, 0, 1, 1
            bezier = materialEaseOut,0, 0, 0.2, 1
            bezier = materialSharp,0.4, 0, 0.6, 1
            
            animation = windows,1,3,materialEaseInOut,slide
            animation = windowsOut,1,3,materialEaseIn,slide
            animation = border,1,10,default
            animation = borderangle,1,8,default
            animation = fade,1,2,materialEaseInOut
            animation = workspaces,1,3,materialEaseInOut,slide
            animation = specialWorkspace,1,3,materialEaseInOut,slidevert
        }
        ''}
        
        # Input configuration
        input {
            kb_layout = us
            follow_mouse = 1
            sensitivity = 0
            
            touchpad {
                natural_scroll = true
                disable_while_typing = true
                tap-to-click = true
            }
        }
        
        # Gestures
        gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
            workspace_swipe_distance = 300
            workspace_swipe_invert = true
            workspace_swipe_min_speed_to_force = 30
            workspace_swipe_cancel_ratio = 0.5
        }
        
        # Dwindle layout
        dwindle {
            pseudotile = true
            preserve_split = true
            smart_split = false
            smart_resizing = true
        }
        
        # Master layout
        master {
            new_is_master = true
            new_on_top = false
            mfact = 0.55
        }
        
        # Misc settings
        misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
            mouse_move_enables_dpms = true
            key_press_enables_dpms = true
            vrr = 1
            animate_manual_resizes = true
            animate_mouse_windowdragging = true
            enable_swallow = true
            swallow_regex = ^(foot|kitty|Alacritty)$
        }
        
        # Core keybinds
        bind = SUPER, Return, exec, $terminal
        bind = SUPER, Q, killactive
        bind = SUPER, M, exit
        bind = SUPER, E, exec, nautilus
        bind = SUPER, V, togglefloating
        bind = SUPER, P, pseudo
        bind = SUPER, J, togglesplit
        bind = SUPER, F, fullscreen
        
        # Quickshell integration
        bind = SUPER, Space, exec, quickshell -c overview
        bind = SUPER, slash, exec, quickshell -c cheatsheet
        bind = SUPER SHIFT, S, exec, quickshell -c screenshot
        
        # Focus movement
        bind = SUPER, left, movefocus, l
        bind = SUPER, right, movefocus, r
        bind = SUPER, up, movefocus, u
        bind = SUPER, down, movefocus, d
        bind = SUPER, h, movefocus, l
        bind = SUPER, l, movefocus, r
        bind = SUPER, k, movefocus, u
        bind = SUPER, j, movefocus, d
        
        # Window movement
        bind = SUPER SHIFT, left, movewindow, l
        bind = SUPER SHIFT, right, movewindow, r
        bind = SUPER SHIFT, up, movewindow, u
        bind = SUPER SHIFT, down, movewindow, d
        bind = SUPER SHIFT, h, movewindow, l
        bind = SUPER SHIFT, l, movewindow, r
        bind = SUPER SHIFT, k, movewindow, u
        bind = SUPER SHIFT, j, movewindow, d
        
        # Resize mode
        bind = SUPER, R, submap, resize
        
        # Special workspaces
        bind = SUPER, S, togglespecialworkspace, magic
        bind = SUPER SHIFT, S, movetoworkspace, special:magic
        
        # Workspace switching (1-10)
        ${lib.concatMapStringsSep "\n" (i: "bind = SUPER, ${toString i}, workspace, ${toString i}") (lib.range 1 cfg.workspaces)}
        
        # Move to workspace (1-10)
        ${lib.concatMapStringsSep "\n" (i: "bind = SUPER SHIFT, ${toString i}, movetoworkspace, ${toString i}") (lib.range 1 cfg.workspaces)}
        
        # Mouse binds
        bindm = SUPER, mouse:272, movewindow
        bindm = SUPER, mouse:273, resizewindow
        
        # Resize submap
        submap = resize
        binde = ,right,resizeactive,10 0
        binde = ,left,resizeactive,-10 0
        binde = ,up,resizeactive,0 -10
        binde = ,down,resizeactive,0 10
        binde = ,l,resizeactive,10 0
        binde = ,h,resizeactive,-10 0
        binde = ,k,resizeactive,0 -10
        binde = ,j,resizeactive,0 10
        bind = ,escape,submap,reset
        submap = reset
        
        # Window rules
        windowrulev2 = float,class:^(pavucontrol)$
        windowrulev2 = float,class:^(nm-connection-editor)$
        windowrulev2 = float,class:^(blueman-manager)$
        windowrulev2 = float,class:^(wlogout)$
        windowrulev2 = float,class:^(quickshell)$
        
        windowrulev2 = opacity 0.9 0.9,class:^(foot)$
        windowrulev2 = opacity 0.9 0.9,class:^(kitty)$
        
        windowrulev2 = size 800 600,class:^(pavucontrol)$
        windowrulev2 = size 600 400,class:^(nm-connection-editor)$
        
        windowrulev2 = center,class:^(pavucontrol)$
        windowrulev2 = center,class:^(nm-connection-editor)$
        windowrulev2 = center,class:^(blueman-manager)$
        
        # Layer rules for quickshell
        layerrule = blur,quickshell
        layerrule = ignorezero,quickshell
        
        # Custom configuration
        ${cfg.customConfig}
      '';
    };

    # Essential Hyprland ecosystem packages
    home.packages = with pkgs; [
      # Core Hyprland tools
      hyprland-qtutils
      hypridle
      hyprlock
      hyprpicker
      hyprsunset
      
      # Wayland utilities
      wl-clipboard
      wl-clip-persist
      
      # Screenshot and screen tools
      grim
      slurp
      
      # System integration
      xdg-desktop-portal-hyprland
      xdg-utils
      
      # Audio control
      pavucontrol
      
      # Network management
      networkmanagerapplet
      
      # Bluetooth
      blueman
    ];

    # Session variables for Hyprland
    home.sessionVariables = {
      # Wayland
      WAYLAND_DISPLAY = "wayland-1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      
      # Qt
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      
      # GTK
      GDK_BACKEND = "wayland,x11";
      
      # Mozilla
      MOZ_ENABLE_WAYLAND = "1";
      
      # SDL
      SDL_VIDEODRIVER = "wayland";
      
      # Java
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
