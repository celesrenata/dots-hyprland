# Touchegg gesture support for dots-hyprland
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.touchegg;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.touchegg = {
    enable = mkEnableOption "Touchegg gesture support";
    
    config = mkOption {
      type = types.lines;
      default = ''
        <touchégg>
          <settings>
            <property name="animation_delay">150</property>
            <property name="action_execute_threshold">20</property>
            <property name="color">auto</property>
            <property name="borderColor">auto</property>
          </settings>
          <application name="All">
            <!-- 3-finger pinch in: Close window -->
            <gesture type="PINCH" fingers="3" direction="IN">
              <action type="CLOSE_WINDOW">
                <animate>true</animate>
                <color>F84A53</color>
                <borderColor>F84A53</borderColor>
              </action>
            </gesture>
            
            <!-- 2-finger tap: Right click -->
            <gesture type="TAP" fingers="2" direction="UNKNOWN">
              <action type="MOUSE_CLICK">
                <button>3</button>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 3-finger tap: Middle click -->
            <gesture type="TAP" fingers="3" direction="UNKNOWN">
              <action type="MOUSE_CLICK">
                <button>2</button>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 4-finger pinch in: Fullscreen mode 0 -->
            <gesture type="PINCH" fingers="4" direction="IN">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch fullscreen 0</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 4-finger pinch out: Fullscreen mode 1 -->
            <gesture type="PINCH" fingers="4" direction="OUT">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch fullscreen 1</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 3-finger swipe left: Next workspace -->
            <gesture type="SWIPE" fingers="3" direction="LEFT">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch workspace +1</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 3-finger swipe right: Previous workspace -->
            <gesture type="SWIPE" fingers="3" direction="RIGHT">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch workspace -1</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 3-finger swipe up: Show overview -->
            <gesture type="SWIPE" fingers="3" direction="UP">
              <action type="RUN_COMMAND">
                <command>pkill fuzzel || fuzzel</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 3-finger swipe down: Show all windows -->
            <gesture type="SWIPE" fingers="3" direction="DOWN">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch overview</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 4-finger swipe left: Move window left -->
            <gesture type="SWIPE" fingers="4" direction="LEFT">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch movewindow l</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 4-finger swipe right: Move window right -->
            <gesture type="SWIPE" fingers="4" direction="RIGHT">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch movewindow r</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 4-finger swipe up: Move window up -->
            <gesture type="SWIPE" fingers="4" direction="UP">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch movewindow u</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
            
            <!-- 4-finger swipe down: Move window down -->
            <gesture type="SWIPE" fingers="4" direction="DOWN">
              <action type="RUN_COMMAND">
                <command>hyprctl dispatch movewindow d</command>
                <repeat>false</repeat>
                <animation>NONE</animation>
                <on>begin</on>
              </action>
            </gesture>
          </application>
          
          <!-- Browser-specific gestures for zoom -->
          <application name="chromium-browser">
            <gesture type="PINCH" fingers="2" direction="IN">
              <action type="SEND_KEYS">
                <repeat>true</repeat>
                <modifiers>Control_L</modifiers>
                <keys>KP_Subtract</keys>
                <decreaseKeys>KP_Add</decreaseKeys>
              </action>
            </gesture>
            <gesture type="PINCH" fingers="2" direction="OUT">
              <action type="SEND_KEYS">
                <repeat>true</repeat>
                <modifiers>Control_L</modifiers>
                <keys>KP_Add</keys>
                <decreaseKeys>KP_Subtract</decreaseKeys>
              </action>
            </gesture>
          </application>
          
          <application name="google-chrome">
            <gesture type="PINCH" fingers="2" direction="IN">
              <action type="SEND_KEYS">
                <repeat>true</repeat>
                <modifiers>Control_L</modifiers>
                <keys>KP_Subtract</keys>
                <decreaseKeys>KP_Add</decreaseKeys>
              </action>
            </gesture>
            <gesture type="PINCH" fingers="2" direction="OUT">
              <action type="SEND_KEYS">
                <repeat>true</repeat>
                <modifiers>Control_L</modifiers>
                <keys>KP_Add</keys>
                <decreaseKeys>KP_Subtract</decreaseKeys>
              </action>
            </gesture>
          </application>
          
          <application name="firefox">
            <gesture type="PINCH" fingers="2" direction="IN">
              <action type="SEND_KEYS">
                <repeat>true</repeat>
                <modifiers>Control_L</modifiers>
                <keys>KP_Subtract</keys>
                <decreaseKeys>KP_Add</decreaseKeys>
              </action>
            </gesture>
            <gesture type="PINCH" fingers="2" direction="OUT">
              <action type="SEND_KEYS">
                <repeat>true</repeat>
                <modifiers>Control_L</modifiers>
                <keys>KP_Add</keys>
                <decreaseKeys>KP_Subtract</decreaseKeys>
              </action>
            </gesture>
          </application>
        </touchégg>
      '';
      description = "Touchegg configuration XML";
    };
  };
  
  config = mkIf cfg.enable {
    # Note: touchegg service needs to be enabled at system level
    # Add this to your NixOS configuration: services.touchegg.enable = true;
    
    # Install touchegg configuration
    xdg.configFile."touchegg/touchegg.conf" = {
      text = cfg.config;
    };
    
    # Install touchegg and management scripts
    home.packages = [ pkgs.touchegg ] ++ [
      (pkgs.writeShellScriptBin "touchegg-restart" ''
        echo "🔄 Restarting touchegg service..."
        sudo systemctl restart touchegg
        echo "✅ Touchegg restarted"
      '')
      
      (pkgs.writeShellScriptBin "touchegg-status" ''
        echo "📊 Touchegg service status:"
        systemctl status touchegg --no-pager
        echo ""
        echo "📄 Touchegg configuration:"
        echo "   ~/.config/touchegg/touchegg.conf"
        if [[ -f ~/.config/touchegg/touchegg.conf ]]; then
          echo "   ✅ Configuration file exists"
        else
          echo "   ❌ Configuration file missing"
        fi
      '')
      
      (pkgs.writeShellScriptBin "touchegg-reload-config" ''
        echo "🔄 Reloading touchegg configuration..."
        if systemctl is-active touchegg >/dev/null 2>&1; then
          sudo systemctl reload touchegg 2>/dev/null || sudo systemctl restart touchegg
          echo "✅ Touchegg configuration reloaded"
        else
          echo "❌ Touchegg service is not running"
          echo "💡 Try: sudo systemctl start touchegg"
        fi
      '')
    ];
    
    # Session variables for touchegg
    home.sessionVariables = {
      TOUCHEGG_CONFIG_PATH = "$HOME/.config/touchegg/touchegg.conf";
    };
  };
}
