pragma Singleton
import QtQuick
import Qt.labs.platform

QtObject {
    id: root
    property string filePath: `${StandardPaths.writableLocation(StandardPaths.ConfigLocation)}/illogical-impulse/config.json`
    property bool ready: true
    
    // Minimal options object for AppSearch
    property QtObject options: QtObject {
        property QtObject search: QtObject {
            property bool sloppy: false
        }
    }
}
