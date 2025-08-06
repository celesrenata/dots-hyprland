pragma Singleton
import QtQuick
import Qt.labs.platform

QtObject {
    id: root
    property string filePath: `${StandardPaths.writableLocation(StandardPaths.ConfigLocation)}/illogical-impulse/config.json`
    property bool ready: true
    
    // Expanded options object for all UI components
    property QtObject options: QtObject {
        // Search options for AppSearch
        property QtObject search: QtObject {
            property bool sloppy: false
        }
        
        // Bar options for Bar.qml
        property QtObject bar: QtObject {
            property bool showBackground: true
        }
        
        // Overview options for OverviewWidget.qml
        property QtObject overview: QtObject {
            property int rows: 3
            property int columns: 6
            property real scale: 1.0
        }
        
        // General UI options
        property QtObject ui: QtObject {
            property var screenList: []
            property var clipboard: null
        }
    }
}
