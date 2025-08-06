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
        
        // DateTime options for DateTime service
        property QtObject time: QtObject {
            property string format: "hh:mm"
            property string dateFormat: "dddd, dd/MM"
        }
        
        // Background options for Background.qml
        property QtObject background: QtObject {
            property int clockX: 100
            property int clockY: 100
            property string wallpaperPath: "/home/user/wallpaper.jpg"
        }
        
        // Cliphist options
        property QtObject cliphist: QtObject {
            property int arbitraryRaceConditionDelay: 100
        }
        
        // General UI options
        property QtObject ui: QtObject {
            property var screenList: []
            property var clipboard: null
        }
    }
}
