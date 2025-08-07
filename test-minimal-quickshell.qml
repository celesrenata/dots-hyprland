//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell

ShellRoot {
    id: shell
    
    // Minimal test - just a simple window
    PanelWindow {
        id: testWindow
        anchors {
            top: true
            left: true
            right: true
        }
        height: 40
        
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            
            Text {
                anchors.centerIn: parent
                text: "🎉 quickshell is working!"
                color: "#cdd6f4"
                font.pixelSize: 16
            }
        }
    }
}
