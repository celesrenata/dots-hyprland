# Custom keybindings based on Celes's actual configuration from 192.168.42.201
# Adapted from AGS to Quickshell integration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.custom-keybinds;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.custom-keybinds = {
    enable = mkEnableOption "Custom keybindings from Celes's actual configuration";
  };
  
  config = mkIf cfg.enable {
    # Create the actual custom keybinds file based on your real configuration
    xdg.configFile."hypr/custom/keybinds.conf" = {
      text = ''
        # Celes's actual keybindings adapted for Quickshell
        # Variables for consistency
        $Primary="Super"
        $Secondary="Control"
        $Tertiary="Shift"
        $Alternate="Alt"
        $MenuButton="Menu"

        # ################### It just works™ keybinds ###################
        # Note: Volume and brightness controls are handled by default keybinds to avoid duplicates

        # ####################################### Applications ########################################
        # Music
        bind = $Primary$Secondary, M, exec, tidal-hifi
        bind = $Primary$Secondary$Tertiary, M, exec, env -u NIXOS_OZONE_WL cider --use-gl=desktop
        bind = $Primary$Secondary$Alternate, M, exec, spotify
        
        # Discord
        bind = $Primary$Secondary, O, exec, vesktop
        
        # Terminal
        bind = $Primary$Secondary, H, exec, foot
        bind = $Primary$Secondary$Tertiary, T, exec, foot sleep 0.01 && nmtui
        
        # File managers
        bind = $Primary$Secondary, J, exec, thunar
        bind = $Primary$Secondary$Tertiary, J, exec, nautilus
        
        # Browsers
        bind = $Primary$Secondary, B, exec, firefox
        bind = $Primary$Secondary$Tertiary, B, exec, chromium 

        # Editors
        bind = $Primary$Secondary, X, exec, subl
        bind = $Primary$Secondary, C, exec, code
        bind = $Primary$Secondary$Tertiary, C, exec, jetbrains-toolbox

        # Calculator
        bind = $Primary$Secondary, 3, exec, ~/.local/bin/wofi-calc
        bind = ,XF86Calculator, exec, ~/.local/bin/wofi-calc
        
        # Flux/Gammastep
        bind = $Primary$Secondary, N, exec, gammastep -O +3000 &
        bind = $Primary$Secondary$Alternate, N, exec, gammastep -0 +6500 &
        
        # Settings
        bind = $Primary$Secondary, I, exec, XDG_CURRENT_DESKTOP="gnome" gnome-control-center
        bind = $Primary$Secondary, V, exec, pavucontrol 
        bind = $Primary$Tertiary, Home, exec, gnome-system-monitor
        bind = $Primary$Alternate, Insert, exec, foot -F btop

        # Actions
        bind = $Primary$Secondary, Period, exec, pkill fuzzel || ~/.local/bin/fuzzel-emoji
        bind = $Alternate, F4, killactive,
        bind = $Secondary$Alternate, Space, togglefloating, 
        bind = $Secondary$Alternate, Q, exec, hyprctl kill
        bind = $Primary$Tertiary$Alternate, Delete, exec, pkill wlogout || wlogout -p layer-shell
        bind = $Primary$Tertiary$Alternate$Secondary, Delete, exec, systemctl poweroff

        # Screenshot, Record, OCR, Color picker, Clipboard history
        bind = $Secondary$Tertiary, D, exec, ~/.local/bin/rubyshot | wl-copy
        bindl =,Print,exec,grim - | wl-copy
        bind = $Secondary$Tertiary, 4, exec, grim -g "$(slurp -d -c D1E5F4BB -b 1B232866 -s 00000000)" - | wl-copy
        bind = $Secondary$Tertiary, 5, exec, ~/.config/ags/scripts/record-script.sh
        bind = $Secondary$Alternate, 5, exec, ~/.config/ags/scripts/record-script.sh --sound
        bind = $Secondary$Tertiary$Alternate, 5, exec, ~/.config/ags/scripts/record-script.sh --fullscreen-sound

        bind = $Secondary$Alternate, C, exec, hyprpicker -a
        bind = $Primary$Alternate, Space, exec, cliphist list | wofi -Iim --dmenu | cliphist decode | wl-copy && wtype -M ctrl v -M ctrl
        bind = $Secondary$Alternate, V, exec, cliphist list | wofi -Iim --dmenu | cliphist decode | wl-copy && wtype -M ctrl v -M ctrl
        bind = $Primary, Menu, exec, tac ~/.local/share/snippets | wofi -Iim --dmenu | sed -z '$ s/\\n$//' | wl-copy && wtype -M ctrl v -M ctrl
        bind = $Alternate, Menu, exec, wtype -M logo c -M logo && wl-paste >> ~/.local/share/snippets && sed '/^[[:space:]]*$/d' -i ~/.local/share/snippets && notify-send "Added to snippets!"
        bind = $Alternate$Tertiary, Menu, exec, tac ~/.local/share/snippets | wofi -Iim --dmenu | xargs -I '%' ~/.local/bin/regexEscape.sh "'%'"| xargs -I '%' sed '/\\(^.*%.*$\\)/d' -i ~/.local/share/snippets && notify-send "Deleted from snippets!"

        # Text-to-image OCR
        bind = $Primary$Secondary$Tertiary,S,exec,grim -g "$(slurp -d -c D1E5F4BB -b 1B232866 -s 00000000)" "tmp.png" && tesseract "tmp.png" - | wl-copy && rm "tmp.png"
        bind = $Secondary$Tertiary,T,exec,grim -g "$(slurp -d -c D1E5F4BB -b 1B232866 -s 00000000)" "tmp.png" && tesseract -l eng "tmp.png" - | wl-copy && rm "tmp.png"
        bind = $Secondary$Tertiary,J,exec,grim -g "$(slurp -d -c D1E5F4BB -b 1B232866 -s 00000000)" "tmp.png" && tesseract -l jpn "tmp.png" - | wl-copy && rm "tmp.png"

        # Media controls (custom keyboard shortcuts only - let defaults handle hardware keys)
        bind = $Secondary$Tertiary, N, exec, playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`
        bind = $Secondary$Tertiary, B, exec, playerctl previous
        bind = $Secondary$Tertiary, P, exec, playerctl play-pause
        # Note: XF86Audio* keys are handled by default keybinds to avoid duplicates

        # Lock screen
        bind = $Primary$Secondary, L, exec, hyprlock 

        # App launcher
        bind = $Primary$Secondary, Slash, exec, pkill anyrun || anyrun

        # ##################################### Quickshell keybinds (adapted from AGS) #####################################
        bindr = $Primary$Secondary, R, exec, hyprctl reload; systemctl --user restart quickshell
        bind = $Primary$Secondary, T, exec, ~/.config/quickshell/ii/scripts/colors/switchwall.sh
        bind = $Alternate, Tab, global, quickshell:overviewToggle
        bind = $Secondary, Space, global, quickshell:overviewToggle
        bind = $Secondary$Alternate, Slash, global, quickshell:cheatsheetToggle
        bind = $Secondary, B, global, quickshell:sidebarLeftToggle
        bind = $Secondary, N, global, quickshell:sidebarRightToggle
        bind = $Secondary, M, global, quickshell:mediaControlsToggle
        bind = $Secondary, K, global, quickshell:oskToggle
        bind = $Primary$Alternate, Delete, global, quickshell:sessionToggle
        bind = $Secondary$Alternate, Delete, exec, foot -F btop

        # ########################### Keybinds for Hyprland ############################
        # Swap windows
        bind = $Secondary$Tertiary, left, movewindow, l
        bind = $Secondary$Tertiary, right, movewindow, r
        bind = $Secondary$Tertiary, up, movewindow, u
        bind = $Secondary$Tertiary, down, movewindow, d
        
        # Move focus
        bind = $Secondary, left, movefocus, l
        bind = $Secondary, right, movefocus, r
        bind = $Alternate, up, movefocus, u
        bind = $Alternate, down, movefocus, d
        bind = $Secondary, BracketLeft, movefocus, l
        bind = $Secondary, BracketRight, movefocus, r

        # Workspace navigation
        bind = $Primary$Secondary, right, workspace, +1
        bind = $Primary$Secondary, left, workspace, -1
        bind = $Primary$Secondary, BracketLeft, workspace, -1
        bind = $Primary$Secondary, BracketRight, workspace, +1
        bind = $Primary$Secondary, up, workspace, -5
        bind = $Primary$Secondary, down, workspace, +5
        bind = $Secondary, Page_Down, workspace, +1
        bind = $Secondary, Page_Up, workspace, -1
        bind = $Primary$Secondary, Page_Down, workspace, +1
        bind = $Primary$Secondary, Page_Up, workspace, -1
        bind = $Secondary$Alternate, Page_Down, movetoworkspace, +1
        bind = $Secondary$Alternate, Page_Up, movetoworkspace, -1
        bind = $Secondary$Tertiary, Page_Down, movetoworkspace, +1
        bind = $Secondary$Tertiary, Page_Up, movetoworkspace, -1
        bind = $Primary$Secondary$Tertiary, Right, movetoworkspace, +1
        bind = $Primary$Secondary$Tertiary, Left, movetoworkspace, -1
        bind = $Secondary$Tertiary, mouse_down, movetoworkspace, -1
        bind = $Secondary$Tertiary, mouse_up, movetoworkspace, +1
        bind = $Secondary$Alternate, mouse_down, movetoworkspace, -1
        bind = $Secondary$Alternate, mouse_up, movetoworkspace, +1

        # Window split ratio
        binde = $Primary$Secondary, Minus, splitratio, -0.1
        binde = $Primary$Secondary, Equal, splitratio, 0.1
        binde = $Secondary, Semicolon, splitratio, -0.1
        binde = $Secondary, Apostrophe, splitratio, 0.1

        # Fullscreen
        bind = $Primary$Secondary, F, fullscreen, 0
        bind = $Primary$Secondary, D, fullscreen, 1
        bind = $Secondary$Alternate, F, fullscreenstate, 0

        # Workspace switching by number
        bind = $Secondary, 1, workspace, 1
        bind = $Secondary, 2, workspace, 2
        bind = $Secondary, 3, workspace, 3
        bind = $Secondary, 4, workspace, 4
        bind = $Secondary, 5, workspace, 5
        bind = $Secondary, 6, workspace, 6
        bind = $Secondary, 7, workspace, 7
        bind = $Secondary, 8, workspace, 8
        bind = $Secondary, 9, workspace, 9
        bind = $Secondary, 0, workspace, 10
        bind = $Primary$Secondary, S, togglespecialworkspace,
        bind = $Alternate, Tab, cyclenext
        bind = $Alternate, Tab, bringactivetotop,

        # Move window to workspace
        bind = $Secondary $Alternate, 1, movetoworkspacesilent, 1
        bind = $Secondary $Alternate, 2, movetoworkspacesilent, 2
        bind = $Secondary $Alternate, 3, movetoworkspacesilent, 3
        bind = $Secondary $Alternate, 4, movetoworkspacesilent, 4
        bind = $Secondary $Alternate, 5, movetoworkspacesilent, 5
        bind = $Secondary $Alternate, 6, movetoworkspacesilent, 6
        bind = $Secondary $Alternate, 7, movetoworkspacesilent, 7
        bind = $Secondary $Alternate, 8, movetoworkspacesilent, 8
        bind = $Secondary $Alternate, 9, movetoworkspacesilent, 9
        bind = $Secondary $Alternate, 0, movetoworkspacesilent, 10
        bind = $Primary$Tertiary$Secondary, Up, movetoworkspacesilent, special
        bind = $Secondary$Alternate, S, movetoworkspacesilent, special

        # Mouse workspace scrolling
        bind = $Secondary, mouse_up, workspace, +1
        bind = $Secondary, mouse_down, workspace, -1
        bind = $Primary$Secondary, mouse_up, workspace, +1
        bind = $Primary$Secondary, mouse_down, workspace, -1

        # Mouse window controls
        bindm = $Primary, mouse:273, resizewindow
        bindm = $Primary$Secondary, mouse:273, resizewindow
        bindm = ,mouse:274, movewindow
        bindm = $Secondary, mouse:273, movewindow
        bindm = $Primary$Secondary, Z, movewindow
        bind = $Primary$Secondary, Backslash, resizeactive, exact 640 480

        # Testing
        bind = $Secondary$Alternate, f12, exec, notify-send "Millis since epoch" "$(date +%s%N | cut -b1-13)" -a 'Hyprland keybind'
        bind = $Secondary$Alternate, Equal, exec, notify-send "Urgent notification" "Ah hell no" -u critical -a 'Hyprland keybind'
      '';
    };
    
    # Install available packages for your keybindings
    home.packages = with pkgs; [
      # Communication
      # vesktop  # May not be available
      
      # Terminal
      foot
      
      # File managers
      # thunar   # May not be available
      nautilus
      
      # Browsers
      firefox
      chromium
      
      # Editors
      vscode
      
      # System utilities
      gnome-control-center
      pavucontrol
      gnome-system-monitor
      btop
      
      # Screenshot and media tools
      grim
      slurp
      wl-clipboard
      hyprpicker
      tesseract
      
      # Media controls
      playerctl
      
      # Clipboard management
      cliphist
      wtype
      
      # Session management
      wlogout
      hyprlock
      
      # Brightness control
      brightnessctl
      
      # Color temperature
      gammastep
      
      # Launchers
      # anyrun   # May not be available
      wofi
      fuzzel
    ];
  };
}
