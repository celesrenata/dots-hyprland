import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    baseWidth: lightDarkButtonGroup.implicitWidth
    forceWidth: true

    Process {
        id: konachanWallProc
        property string status: ""
        command: ["bash", "-c", FileUtils.trimFileProtocol(`${Directories.scriptPath}/colors/random_konachan_wall.sh`)]
        stdout: SplitParser {
            onRead: data => {
                console.log(`Konachan wall proc output: ${data}`);
                konachanWallProc.status = data.trim();
            }
        }
    }

    ContentSection {
        title: Translation.tr("Colors & Wallpaper")

        // Light/Dark mode preference
        ButtonGroup {
            id: lightDarkButtonGroup
            Layout.fillWidth: true
            LightDarkPreferenceButton {
                dark: false
            }
            LightDarkPreferenceButton {
                dark: true
            }
        }

        // Material palette selection
        ContentSubsection {
            title: Translation.tr("Material palette")
            ConfigSelectionArray {
                currentValue: Config.options.appearance.palette.type
                configOptionName: "appearance.palette.type"
                onSelected: (newValue) => {
                    Config.options.appearance.palette.type = newValue;
                    Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`])
                }
                options: [
                    {"value": "auto", "displayName": Translation.tr("Auto")},
                    {"value": "scheme-content", "displayName": Translation.tr("Content")},
                    {"value": "scheme-expressive", "displayName": Translation.tr("Expressive")},
                    {"value": "scheme-fidelity", "displayName": Translation.tr("Fidelity")},
                    {"value": "scheme-fruit-salad", "displayName": Translation.tr("Fruit Salad")},
                    {"value": "scheme-monochrome", "displayName": Translation.tr("Monochrome")},
                    {"value": "scheme-neutral", "displayName": Translation.tr("Neutral")},
                    {"value": "scheme-rainbow", "displayName": Translation.tr("Rainbow")},
                    {"value": "scheme-tonal-spot", "displayName": Translation.tr("Tonal Spot")}
                ]
            }
        }


        // Wallpaper selection
        ContentSubsection {
            title: Translation.tr("Wallpaper")
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                RippleButtonWithIcon {
                    id: rndWallBtn
                    buttonRadius: Appearance.rounding.small
                    materialIcon: "wallpaper"
                    mainText: konachanWallProc.running ? Translation.tr("Be patient...") : Translation.tr("Random: Konachan")
                    onClicked: {
                        console.log(konachanWallProc.command.join(" "))
                        konachanWallProc.running = true;
                    }
                    StyledToolTip {
                        content: Translation.tr("Random SFW Anime wallpaper from Konachan\nImage is saved to ~/Pictures/Wallpapers")
                    }
                }
                RippleButtonWithIcon {
                    materialIcon: "wallpaper"
                    StyledToolTip {
                        content: Translation.tr("Pick wallpaper image on your system")
                    }
                    onClicked: {
                        Quickshell.execDetached(`${Directories.wallpaperSwitchScriptPath}`)
                    }
                    mainContentComponent: Component {
                        RowLayout {
                            spacing: 10
                            StyledText {
                                font.pixelSize: Appearance.font.pixelSize.small
                                text: Translation.tr("Choose file")
                                color: Appearance.colors.colOnSecondaryContainer
                            }
                            RowLayout {
                                spacing: 3
                                KeyboardKey {
                                    key: "Ctrl"
                                }
                                KeyboardKey {
                                    key: "󰖳"
                                }
                                StyledText {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "+"
                                }
                                KeyboardKey {
                                    key: "T"
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledText {
            Layout.topMargin: 5
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("Alternatively use /dark, /light, /img in the launcher")
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }
    
    }

    ContentSection {
        title: Translation.tr("Decorations & Effects")

        ContentSubsection {
            title: Translation.tr("Transparency")

            ConfigRow {
                ConfigSwitch {
                    text: Translation.tr("Enable")
                    checked: Config.options.appearance.transparency
                    onCheckedChanged: {
                        Config.options.appearance.transparency = checked;
                    }
                    StyledToolTip {
                        content: Translation.tr("Might look ass. Unsupported.")
                    }
                }
            }
        }

        Loader {
            active: Config.ready
            sourceComponent: ContentSubsection {
                title: Translation.tr("Terminal Effects")

                ConfigRow {
                    uniform: true
                    ConfigSwitch {
                        text: Translation.tr("Transparency")
                        checked: Config.options.terminal?.transparency ?? true
                        
                        // Add debugging for all possible events
                        Component.onCompleted: {
                            console.log("Transparency toggle created, initial checked:", checked);
                            Quickshell.execDetached(["bash", "-c", "echo 'Toggle created with checked=" + checked + "' >> /tmp/transparency_debug.log"]);
                        }
                        
                        onCheckedChanged: {
                            // DEBUG: Check what Config.options actually contains
                            console.log("Config.options:", JSON.stringify(Config.options));
                            console.log("Config.options.terminal:", JSON.stringify(Config.options.terminal));
                            
                            // Skip config assignment for now and just make the toggle work
                            let transparencyValue = checked ? "transparent" : "opaque";
                            Quickshell.execDetached(["bash", "-c", `
                                mkdir -p ~/.local/state/quickshell/user/generated/terminal && 
                                echo "${transparencyValue}" > ~/.local/state/quickshell/user/generated/terminal/transparency && 
                                ~/.config/quickshell/scripts/colors/applycolor.sh
                            `]);
                            
                            console.log("Terminal transparency toggled:", checked, "->", transparencyValue);
                        }
                        
                        onClicked: {
                            console.log("onClicked triggered!");
                            Quickshell.execDetached(["bash", "-c", "echo 'onClicked event' >> /tmp/transparency_debug.log"]);
                        }
                        
                        onPressed: {
                            console.log("onPressed triggered!");
                            Quickshell.execDetached(["bash", "-c", "echo 'onPressed event' >> /tmp/transparency_debug.log"]);
                        }
                        
                        onReleased: {
                            console.log("onReleased triggered!");
                            Quickshell.execDetached(["bash", "-c", "echo 'onReleased event' >> /tmp/transparency_debug.log"]);
                        }
                        
                        StyledToolTip {
                            visible: parent.hovered
                            content: Translation.tr("Enable/disable terminal transparency\nApplies immediately to all terminals")
                        }
                    }
                }

                ConfigSpinBox {
                    text: Translation.tr("Terminal opacity (%)")
                    value: Config.options.terminal?.opacity ?? 80
                    from: 10
                    to: 100
                    stepSize: 5
                    
                    onValueChanged: {
                        if (!Config.options.terminal) Config.options.terminal = {};
                        Config.options.terminal.opacity = value;
                        
                        // Update term_alpha in applycolor.sh and also save to opacity file for transparency system
                        Quickshell.execDetached(["bash", "-c", `
                            sed -i 's/^term_alpha=.*/term_alpha=${value}/' ~/.config/quickshell/scripts/colors/applycolor.sh && 
                            mkdir -p ~/.local/state/quickshell/user/generated/terminal && 
                            echo "${value}" > ~/.local/state/quickshell/user/generated/terminal/opacity && 
                            ~/.config/quickshell/scripts/colors/applycolor.sh
                        `]);
                    }
                }

                StyledText {
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("Changes apply to new terminal instances")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }
        }

        Loader {
            active: Config.ready
            sourceComponent: ContentSubsection {
                title: Translation.tr("Blur Effects")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Enable blur")
                    checked: Config.options.blur?.enabled ?? true
                    onCheckedChanged: {
                        if (!Config.options.blur) Config.options.blur = {};
                        Config.options.blur.enabled = checked;
                        // Apply blur setting via Hyprland
                        Quickshell.execDetached(["hyprctl", "keyword", "decoration:blur:enabled", checked ? "1" : "0"]);
                    }
                    StyledToolTip {
                        visible: parent.hovered
                        content: Translation.tr("Enable blur on transparent elements\nDoesn't affect performance unless you have transparent windows")
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("X-ray mode")
                    enabled: Config.options.blur?.enabled ?? true
                    checked: Config.options.blur?.xray ?? false
                    onCheckedChanged: {
                        if (!Config.options.blur) Config.options.blur = {};
                        Config.options.blur.xray = checked;
                        // Apply X-ray setting via Hyprland
                        Quickshell.execDetached(["hyprctl", "keyword", "decoration:blur:xray", checked ? "1" : "0"]);
                    }
                    StyledToolTip {
                        visible: parent.hovered
                        content: Translation.tr("Make everything behind a window except wallpaper not rendered on blur surface\nRecommended for better performance")
                    }
                }
            }

            ConfigSpinBox {
                text: Translation.tr("Blur size")
                enabled: Config.options.blur?.enabled ?? true
                value: Config.options.blur?.size ?? 8
                from: 1
                to: 50
                stepSize: 1
                onValueChanged: {
                    if (!Config.options.blur) Config.options.blur = {};
                    Config.options.blur.size = value;
                    // Apply blur size via Hyprland
                    Quickshell.execDetached(["hyprctl", "keyword", "decoration:blur:size", value.toString()]);
                }
                StyledToolTip {
                    visible: parent.hovered
                    content: Translation.tr("Adjust blur radius\nHigher = more color spread\nGenerally doesn't affect performance")
                }
            }

            ConfigSpinBox {
                text: Translation.tr("Blur passes")
                enabled: Config.options.blur?.enabled ?? true
                value: Config.options.blur?.passes ?? 4
                from: 1
                to: 10
                stepSize: 1
                onValueChanged: {
                    if (!Config.options.blur) Config.options.blur = {};
                    Config.options.blur.passes = value;
                    // Apply blur passes via Hyprland
                    Quickshell.execDetached(["hyprctl", "keyword", "decoration:blur:passes", value.toString()]);
                }
                StyledToolTip {
                    visible: parent.hovered
                    content: Translation.tr("Number of blur algorithm runs\nMore passes = more spread and power consumption\n4 is recommended")
                }
            }
        }
        }

        ContentSubsection {
            title: Translation.tr("Fake screen rounding")

            ButtonGroup {
                id: fakeScreenRoundingButtonGroup
                property int selectedPolicy: Config.options.appearance.fakeScreenRounding
                spacing: 2
                SelectionGroupButton {
                    property int value: 0
                    leftmost: true
                    buttonText: Translation.tr("No")
                    toggled: (fakeScreenRoundingButtonGroup.selectedPolicy === value)
                    onClicked: {
                        Config.options.appearance.fakeScreenRounding = value;
                    }
                }
                SelectionGroupButton {
                    property int value: 1
                    buttonText: Translation.tr("Yes")
                    toggled: (fakeScreenRoundingButtonGroup.selectedPolicy === value)
                    onClicked: {
                        Config.options.appearance.fakeScreenRounding = value;
                    }
                }
                SelectionGroupButton {
                    property int value: 2
                    rightmost: true
                    buttonText: Translation.tr("When not fullscreen")
                    toggled: (fakeScreenRoundingButtonGroup.selectedPolicy === value)
                    onClicked: {
                        Config.options.appearance.fakeScreenRounding = value;
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Shell windows")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Title bar")
                    checked: Config.options.windows.showTitlebar
                    onCheckedChanged: {
                        Config.options.windows.showTitlebar = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Center title")
                    checked: Config.options.windows.centerTitle
                    onCheckedChanged: {
                        Config.options.windows.centerTitle = checked;
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Wallpaper parallax")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    text: Translation.tr("Depends on workspace")
                    checked: Config.options.background.parallax.enableWorkspace
                    onCheckedChanged: {
                        Config.options.background.parallax.enableWorkspace = checked;
                    }
                }
                ConfigSwitch {
                    text: Translation.tr("Depends on sidebars")
                    checked: Config.options.background.parallax.enableSidebar
                    onCheckedChanged: {
                        Config.options.background.parallax.enableSidebar = checked;
                    }
                }
            }
            ConfigSpinBox {
                text: Translation.tr("Preferred wallpaper zoom (%)")
                value: Config.options.background.parallax.workspaceZoom * 100
                from: 100
                to: 150
                stepSize: 1
                onValueChanged: {
                    console.log(value/100)
                    Config.options.background.parallax.workspaceZoom = value / 100;
                }
            }
        }
    }
}