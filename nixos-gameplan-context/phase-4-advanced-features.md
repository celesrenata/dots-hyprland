# Phase 4: Advanced Features Implementation

## Overview
This phase implements the advanced features that make dots-hyprland unique: AI integration, advanced widgets, comprehensive theming, and quality-of-life enhancements. Based on the wiki analysis, these features provide the "wow factor" but aren't critical for basic functionality.

## Advanced Features Analysis

### From Wiki Analysis - Key Advanced Features

#### 1. AI Integration (Gemini & Ollama)
- **Location**: `.config/quickshell/ii/services/Ai.qml`
- **Features**: Chat interface, code generation, image analysis
- **APIs**: Google Gemini API, local Ollama models
- **UI**: Sidebar integration, dedicated chat windows

#### 2. Advanced Widget System
- **Overview Widget**: Live window previews, drag-and-drop workspace management
- **Sidebars**: Left (AI, calendar, todo) and Right (system info, controls)
- **Notifications**: Grouped, actionable, persistent
- **Media Controls**: MPRIS integration, album art, progress

#### 3. Material You Theming
- **Dynamic Colors**: Generated from wallpaper using matugen
- **Application Integration**: GTK, Qt, terminal, all widgets
- **Theme Switching**: Light/dark mode, accent colors
- **Accessibility**: High contrast, color blind friendly

#### 4. Quality of Life Features
- **Screen Corners**: Hot corners for actions
- **On-Screen Keyboard**: Virtual keyboard for touch devices
- **Session Management**: Lock, logout, shutdown widgets
- **Cheatsheet**: Interactive keybind reference

## Implementation Strategy

### 1. AI Integration Implementation

#### AI Service Configuration (`modules/components/ai.nix`)
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.ai;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.ai = {
    enable = mkEnableOption "AI integration for dots-hyprland";

    providers = {
      gemini = {
        enable = mkEnableOption "Google Gemini AI";
        apiKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to file containing Gemini API key";
          example = "/run/secrets/gemini-api-key";
        };
        model = mkOption {
          type = types.str;
          default = "gemini-pro";
          description = "Gemini model to use";
        };
      };

      ollama = {
        enable = mkEnableOption "Ollama local AI";
        endpoint = mkOption {
          type = types.str;
          default = "http://localhost:11434";
          description = "Ollama API endpoint";
        };
        models = mkOption {
          type = types.listOf types.str;
          default = [ "llama2" "codellama" ];
          description = "Available Ollama models";
        };
        autoStart = mkEnableOption "Auto-start Ollama service" // { default = true; };
      };
    };

    features = {
      chat = mkEnableOption "AI chat interface" // { default = true; };
      codeGeneration = mkEnableOption "Code generation assistance";
      imageAnalysis = mkEnableOption "Image analysis capabilities";
      translation = mkEnableOption "Text translation";
    };

    ui = {
      sidebarIntegration = mkEnableOption "Integrate AI in sidebar" // { default = true; };
      floatingWindow = mkEnableOption "Floating AI chat window";
      keybind = mkOption {
        type = types.str;
        default = "SUPER_SHIFT_A";
        description = "Keybind to open AI interface";
      };
    };
  };

  config = mkIf cfg.enable {
    # Ollama service
    systemd.user.services.ollama = mkIf (cfg.providers.ollama.enable && cfg.providers.ollama.autoStart) {
      Unit = {
        Description = "Ollama local AI service";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.ollama}/bin/ollama serve";
        Environment = [
          "OLLAMA_HOST=127.0.0.1:11434"
          "OLLAMA_MODELS=${config.xdg.dataHome}/ollama/models"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # AI configuration for Quickshell
    xdg.configFile."quickshell/ii/defaults/ai/config.json".text = builtins.toJSON {
      providers = {
        gemini = mkIf cfg.providers.gemini.enable {
          enabled = true;
          model = cfg.providers.gemini.model;
          apiKeyFile = cfg.providers.gemini.apiKeyFile;
        };
        ollama = mkIf cfg.providers.ollama.enable {
          enabled = true;
          endpoint = cfg.providers.ollama.endpoint;
          models = cfg.providers.ollama.models;
        };
      };
      features = cfg.features;
      ui = cfg.ui;
    };

    # Required packages
    home.packages = with pkgs; [
      curl # For API calls
      jq   # For JSON processing
    ] ++ optionals cfg.providers.ollama.enable [
      ollama
    ];

    # Hyprland keybind for AI
    programs.dots-hyprland.hyprland.customConfig = mkIf cfg.ui.keybind != null ''
      bind = ${cfg.ui.keybind}, exec, quickshell -c ai-chat
    '';
  };
}
```

#### AI Service Script Integration
```nix
# packages/ai-integration/default.nix
{ lib, pkgs, writeShellScriptBin }:

let
  aiChatScript = writeShellScriptBin "ai-chat" ''
    #!/usr/bin/env bash
    
    CONFIG_FILE="$HOME/.config/quickshell/ii/defaults/ai/config.json"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
      echo "AI configuration not found"
      exit 1
    fi
    
    # Read configuration
    GEMINI_ENABLED=$(${pkgs.jq}/bin/jq -r '.providers.gemini.enabled // false' "$CONFIG_FILE")
    OLLAMA_ENABLED=$(${pkgs.jq}/bin/jq -r '.providers.ollama.enabled // false' "$CONFIG_FILE")
    
    if [[ "$GEMINI_ENABLED" == "true" ]]; then
      API_KEY_FILE=$(${pkgs.jq}/bin/jq -r '.providers.gemini.apiKeyFile' "$CONFIG_FILE")
      if [[ -f "$API_KEY_FILE" ]]; then
        export GEMINI_API_KEY=$(cat "$API_KEY_FILE")
      fi
    fi
    
    # Launch AI interface
    ${pkgs.quickshell}/bin/quickshell -c ai-interface
  '';

  ollamaHealthCheck = writeShellScriptBin "ollama-health" ''
    #!/usr/bin/env bash
    
    ENDPOINT="$1"
    if [[ -z "$ENDPOINT" ]]; then
      ENDPOINT="http://localhost:11434"
    fi
    
    ${pkgs.curl}/bin/curl -s "$ENDPOINT/api/tags" > /dev/null
    echo $?
  '';
in
{
  ai-chat = aiChatScript;
  ollama-health = ollamaHealthCheck;
}
```

### 2. Advanced Widget System

#### Overview Widget Implementation
Based on `.config/quickshell/ii/modules/overview/`:

```nix
# configs/quickshell/ii/modules/overview/Overview.qml.template
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: overview
    
    property bool visible: false
    property var workspaces: []
    property var windows: []
    
    color: "@BACKGROUND_COLOR@"
    radius: 12
    
    // Window previews with drag-and-drop
    GridView {
        id: windowGrid
        anchors.fill: parent
        anchors.margins: 20
        
        cellWidth: 300
        cellHeight: 200
        
        model: overview.windows
        
        delegate: Rectangle {
            width: windowGrid.cellWidth - 10
            height: windowGrid.cellHeight - 10
            
            color: "@SURFACE_COLOR@"
            radius: 8
            border.color: "@OUTLINE_COLOR@"
            border.width: 1
            
            // Window preview
            Image {
                id: windowPreview
                anchors.fill: parent
                anchors.margins: 4
                source: modelData.preview || ""
                fillMode: Image.PreserveAspectFit
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 30
                    color: "@SURFACE_VARIANT_COLOR@"
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData.title || "Unknown"
                        color: "@ON_SURFACE_COLOR@"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }
            }
            
            // Drag and drop functionality
            MouseArea {
                anchors.fill: parent
                drag.target: parent
                
                onClicked: {
                    // Focus window
                    HyprlandIpc.dispatch("focuswindow", "address:" + modelData.address)
                    overview.visible = false
                }
                
                onReleased: {
                    // Handle workspace drop
                    var workspace = getWorkspaceAt(parent.x, parent.y)
                    if (workspace) {
                        HyprlandIpc.dispatch("movetoworkspace", workspace + ",address:" + modelData.address)
                    }
                }
            }
        }
    }
    
    // Workspace indicators
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        spacing: 10
        
        Repeater {
            model: overview.workspaces
            
            Rectangle {
                width: 40
                height: 8
                radius: 4
                color: modelData.active ? "@PRIMARY_COLOR@" : "@OUTLINE_COLOR@"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        HyprlandIpc.dispatch("workspace", modelData.id)
                        overview.visible = false
                    }
                }
            }
        }
    }
    
    // Search functionality
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        
        width: 400
        height: 40
        radius: 20
        color: "@SURFACE_COLOR@"
        border.color: "@OUTLINE_COLOR@"
        
        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.margins: 15
            
            color: "@ON_SURFACE_COLOR@"
            font.pixelSize: 14
            placeholderText: "Search applications, calculate, or run commands..."
            
            onTextChanged: {
                // Implement search logic
                performSearch(text)
            }
            
            Keys.onReturnPressed: {
                // Execute search result
                executeSearchResult()
            }
        }
    }
    
    function performSearch(query) {
        // Implementation for search functionality
        // - Application search
        // - Calculator
        // - Command execution
        // - Directory navigation
    }
    
    function executeSearchResult() {
        // Execute the selected search result
    }
    
    function getWorkspaceAt(x, y) {
        // Determine workspace based on drop position
        return null
    }
}
```

#### Sidebar Implementation
```nix
# configs/quickshell/ii/modules/sidebarLeft/SidebarLeft.qml.template
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebarLeft
    
    property bool visible: false
    
    width: 350
    height: Screen.height
    color: "@SURFACE_COLOR@"
    
    // Slide animation
    x: visible ? 0 : -width
    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 10
        
        ColumnLayout {
            width: parent.width
            spacing: 15
            
            // AI Chat Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    
                    Text {
                        text: "AI Assistant"
                        color: "@ON_SURFACE_COLOR@"
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        TextArea {
                            id: aiChatArea
                            placeholderText: "Ask me anything..."
                            color: "@ON_SURFACE_COLOR@"
                            wrapMode: TextArea.Wrap
                            readOnly: true
                        }
                    }
                    
                    TextField {
                        id: aiInput
                        Layout.fillWidth: true
                        placeholderText: "Type your message..."
                        color: "@ON_SURFACE_COLOR@"
                        
                        onAccepted: {
                            sendAiMessage(text)
                            text = ""
                        }
                    }
                }
            }
            
            // Calendar Widget
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 12
                
                // Calendar implementation
            }
            
            // Todo List
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 12
                
                // Todo list implementation
            }
            
            // System Information
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 12
                
                // System info implementation
            }
        }
    }
    
    function sendAiMessage(message) {
        // Send message to AI service
        aiChatArea.append("You: " + message)
        
        // Call AI service (implementation depends on provider)
        callAiService(message)
    }
    
    function callAiService(message) {
        // Implementation for AI service calls
    }
}
```

### 3. Material You Theming System

#### Advanced Color Generation
```nix
# lib/material-colors.nix
{ lib, pkgs }:

let
  generateAdvancedColors = { wallpaper, mode ? "dark", contrast ? 0.0 }: 
    pkgs.writeShellScript "generate-advanced-colors" ''
      #!/usr/bin/env bash
      
      WALLPAPER="${wallpaper}"
      MODE="${mode}"
      CONTRAST="${toString contrast}"
      CACHE_DIR="$HOME/.cache/dots-hyprland/colors"
      
      mkdir -p "$CACHE_DIR"
      
      # Generate base colors with matugen
      ${pkgs.matugen}/bin/matugen image "$WALLPAPER" \
        --mode "$MODE" \
        --type scheme-content \
        --contrast "$CONTRAST" \
        --json > "$CACHE_DIR/base-colors.json"
      
      # Generate extended color palette
      python3 ${./color-processor.py} \
        --input "$CACHE_DIR/base-colors.json" \
        --output "$CACHE_DIR" \
        --mode "$MODE"
      
      # Generate application-specific themes
      ${generateGtkTheme}/bin/generate-gtk-theme "$CACHE_DIR"
      ${generateQtTheme}/bin/generate-qt-theme "$CACHE_DIR"
      ${generateTerminalTheme}/bin/generate-terminal-theme "$CACHE_DIR"
      ${generateHyprlandTheme}/bin/generate-hyprland-theme "$CACHE_DIR"
      
      # Apply themes
      ${applyThemes}/bin/apply-themes "$CACHE_DIR"
      
      echo "Material You theming complete"
    '';

  generateGtkTheme = pkgs.writeShellScriptBin "generate-gtk-theme" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    GTK_DIR="$HOME/.config/gtk-3.0"
    
    mkdir -p "$GTK_DIR"
    
    # Read colors
    PRIMARY=$(${pkgs.jq}/bin/jq -r '.colors.primary' "$CACHE_DIR/base-colors.json")
    SURFACE=$(${pkgs.jq}/bin/jq -r '.colors.surface' "$CACHE_DIR/base-colors.json")
    
    # Generate GTK CSS
    cat > "$GTK_DIR/gtk.css" << EOF
    @define-color accent_color $PRIMARY;
    @define-color accent_bg_color $PRIMARY;
    @define-color accent_fg_color white;
    @define-color destructive_color #ff6b6b;
    @define-color destructive_bg_color #ff6b6b;
    @define-color destructive_fg_color white;
    @define-color success_color #51cf66;
    @define-color success_bg_color #51cf66;
    @define-color success_fg_color white;
    @define-color warning_color #ffd43b;
    @define-color warning_bg_color #ffd43b;
    @define-color warning_fg_color black;
    @define-color error_color #ff6b6b;
    @define-color error_bg_color #ff6b6b;
    @define-color error_fg_color white;
    @define-color window_bg_color $SURFACE;
    @define-color window_fg_color white;
    @define-color view_bg_color $SURFACE;
    @define-color view_fg_color white;
    @define-color headerbar_bg_color $SURFACE;
    @define-color headerbar_fg_color white;
    @define-color headerbar_border_color rgba(255,255,255,0.1);
    @define-color headerbar_backdrop_color $SURFACE;
    @define-color headerbar_shade_color rgba(0,0,0,0.1);
    @define-color card_bg_color rgba(255,255,255,0.05);
    @define-color card_fg_color white;
    @define-color card_shade_color rgba(0,0,0,0.1);
    @define-color dialog_bg_color $SURFACE;
    @define-color dialog_fg_color white;
    @define-color popover_bg_color $SURFACE;
    @define-color popover_fg_color white;
    @define-color shade_color rgba(0,0,0,0.1);
    @define-color scrollbar_outline_color rgba(255,255,255,0.1);
    EOF
  '';

  applyThemes = pkgs.writeShellScriptBin "apply-themes" ''
    #!/usr/bin/env bash
    
    CACHE_DIR="$1"
    
    # Reload GTK applications
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    
    # Reload Qt applications
    export QT_STYLE_OVERRIDE="kvantum"
    
    # Reload Quickshell
    ${pkgs.systemd}/bin/systemctl --user reload-or-restart quickshell.service
    
    # Send notification
    ${pkgs.libnotify}/bin/notify-send "Material You" "Theme updated successfully" \
      --icon="preferences-desktop-theme"
  '';
in
{
  inherit generateAdvancedColors generateGtkTheme applyThemes;
}
```

### 4. Quality of Life Features

#### Screen Corners Implementation
```nix
# configs/quickshell/ii/modules/screenCorners/ScreenCorners.qml.template
import QtQuick
import Quickshell

ShellRoot {
    // Top-left corner
    PanelWindow {
        id: topLeftCorner
        anchors {
            top: true
            left: true
        }
        width: 1
        height: 1
        
        Rectangle {
            width: 20
            height: 20
            color: "transparent"
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                
                onEntered: {
                    // Trigger action (e.g., show overview)
                    triggerCornerAction("top-left")
                }
            }
        }
    }
    
    // Top-right corner - brightness control
    PanelWindow {
        id: topRightCorner
        anchors {
            top: true
            right: true
        }
        width: 1
        height: 1
        
        Rectangle {
            width: 20
            height: 20
            color: "transparent"
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                
                onWheel: {
                    // Brightness control
                    var delta = wheel.angleDelta.y > 0 ? 5 : -5
                    adjustBrightness(delta)
                }
            }
        }
    }
    
    function triggerCornerAction(corner) {
        switch(corner) {
            case "top-left":
                // Show overview
                break
            case "top-right":
                // Show brightness OSD
                break
            case "bottom-left":
                // Show sidebar
                break
            case "bottom-right":
                // Show session menu
                break
        }
    }
    
    function adjustBrightness(delta) {
        // Brightness adjustment implementation
    }
}
```

#### Session Management
```nix
# configs/quickshell/ii/modules/session/SessionManager.qml.template
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sessionManager
    
    property bool visible: false
    
    width: 300
    height: 200
    color: "@SURFACE_COLOR@"
    radius: 12
    border.color: "@OUTLINE_COLOR@"
    
    GridLayout {
        anchors.centerIn: parent
        columns: 2
        rowSpacing: 15
        columnSpacing: 15
        
        // Lock
        Button {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            
            background: Rectangle {
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 8
            }
            
            contentItem: Column {
                spacing: 5
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🔒"
                    font.pixelSize: 24
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Lock"
                    color: "@ON_SURFACE_COLOR@"
                    font.pixelSize: 12
                }
            }
            
            onClicked: {
                executeCommand("hyprlock")
                sessionManager.visible = false
            }
        }
        
        // Logout
        Button {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            
            background: Rectangle {
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 8
            }
            
            contentItem: Column {
                spacing: 5
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🚪"
                    font.pixelSize: 24
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Logout"
                    color: "@ON_SURFACE_COLOR@"
                    font.pixelSize: 12
                }
            }
            
            onClicked: {
                executeCommand("hyprctl dispatch exit")
                sessionManager.visible = false
            }
        }
        
        // Reboot
        Button {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            
            background: Rectangle {
                color: "@SURFACE_VARIANT_COLOR@"
                radius: 8
            }
            
            contentItem: Column {
                spacing: 5
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🔄"
                    font.pixelSize: 24
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Reboot"
                    color: "@ON_SURFACE_COLOR@"
                    font.pixelSize: 12
                }
            }
            
            onClicked: {
                executeCommand("systemctl reboot")
                sessionManager.visible = false
            }
        }
        
        // Shutdown
        Button {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            
            background: Rectangle {
                color: "@ERROR_COLOR@"
                radius: 8
            }
            
            contentItem: Column {
                spacing: 5
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "⏻"
                    font.pixelSize: 24
                    color: "@ON_ERROR_COLOR@"
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Shutdown"
                    color: "@ON_ERROR_COLOR@"
                    font.pixelSize: 12
                }
            }
            
            onClicked: {
                executeCommand("systemctl poweroff")
                sessionManager.visible = false
            }
        }
    }
    
    function executeCommand(command) {
        // Execute system command
        Qt.callLater(function() {
            Process.start(command)
        })
    }
}
```

## Testing Strategy for Advanced Features

### 1. AI Integration Testing
```bash
# Test AI services
systemctl --user status ollama
curl -X POST http://localhost:11434/api/generate -d '{"model":"llama2","prompt":"Hello"}'

# Test Gemini integration (with API key)
export GEMINI_API_KEY="your-key-here"
quickshell -c ai-test
```

### 2. Widget System Testing
```nix
# Test configuration with advanced widgets enabled
{
  programs.dots-hyprland = {
    enable = true;
    
    features = {
      overview = true;
      sidebar = true;
      notifications = true;
      mediaControls = true;
      screenCorners = true;
      onScreenKeyboard = true;
      cheatsheet = true;
    };
    
    ai = {
      enable = true;
      providers.ollama.enable = true;
    };
  };
}
```

### 3. Performance Testing
```bash
# Monitor resource usage
htop
systemd-analyze --user
journalctl --user -u quickshell -f

# Test startup time
time quickshell --test-startup
```

## Action Items for Phase 4

### Week 1: AI Integration
1. **Implement AI service configuration**
2. **Create Ollama integration**
3. **Add Gemini API support**
4. **Test AI chat functionality**

### Week 2: Advanced Widgets
1. **Implement overview widget with previews**
2. **Create advanced sidebar components**
3. **Add notification system enhancements**
4. **Implement media controls**

### Week 3: Theming & QoL
1. **Advanced Material You theming**
2. **Screen corners implementation**
3. **Session management widgets**
4. **On-screen keyboard integration**

### Week 4: Polish & Integration
1. **Performance optimization**
2. **Feature integration testing**
3. **User experience refinement**
4. **Documentation and examples**

## Expected Outcomes

### Deliverables
1. **Complete AI integration** - Gemini and Ollama support
2. **Advanced widget system** - All premium features functional
3. **Comprehensive theming** - Material You across all applications
4. **Quality of life features** - Screen corners, session management, etc.
5. **Performance optimization** - Smooth, responsive experience
6. **User customization** - Extensive configuration options

### Success Criteria
- [ ] AI chat interface functional with both providers
- [ ] Overview widget shows live previews and drag-and-drop works
- [ ] Sidebars contain all planned widgets and features
- [ ] Material You theming applies to all applications
- [ ] Screen corners and session management work reliably
- [ ] Performance remains acceptable with all features enabled
- [ ] All features can be configured and customized
- [ ] Ready for Phase 5 (NixOS-Specific Adaptations)
