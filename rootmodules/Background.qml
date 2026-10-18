import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtCore
import qs.common
import qs

Scope {
    id: root
    //property var screen

    property string backgroundPath: Quickshell.env("HOME") + "/.local/share/wallpaper.jpg"

    Settings {
        property alias backgroundPath: root.backgroundPath
    }

    ColorQuantizer {
        id: quantizer
        source: Qt.resolvedUrl(root.backgroundPath)
        depth: 3
        rescaleSize: 64
        onColorsChanged: {
            let a = colors[6];
            while (a.r < 0.5 && a.g < 0.5 && a.b < 0.5)
                a = Qt.lighter(a, 1.5);
            //if (a.r < 0.5 && a.g < 0.5 && a.b < 0.5)
            //	a = Qt.lighter(a, 1.5)
            while (a.r > 0.6 && a.g > 0.6 && a.b > 0.6)
                a = Qt.darker(a, 1.25);
            if (Math.max(Math.abs(a.r - a.g), Math.abs(a.r - a.b), Math.abs(a.g - a.b)) < 0.1 && (a.r != a.g || a.r != a.b)) {
                let tmp = Math.max(a.r, a.g, a.b);
                if (a.r == tmp)
                    a.r *= 1.5;
                if (a.g == tmp)
                    a.g *= 1.5;
                if (a.b == tmp)
                    a.b *= 1.5;
            }

            let a1 = Qt.lighter(a, 1.5);
            Globals.settings.accent = a;
            Globals.settings.accent1 = a1;
            //Globals.settings.alternate = colors[4]
        }
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string) {
            root.backgroundPath = path;
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property var modelData
            PanelWindow {
                screen: modelData
                implicitWidth: screen.width
                implicitHeight: screen.height
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "wallpaper"
                color: "transparent"

                AnimatedImage {
                    id: mainImage
                    asynchronous: true
                    cache: true
                    onStatusChanged: playing = (status == AnimatedImage.Ready)
                    anchors.fill: parent
                    source: root.backgroundPath
                    fillMode: Image.PreserveAspectCrop
                }
            }
            PanelWindow {
                screen: modelData
                implicitWidth: screen.width
                implicitHeight: screen.height
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "wallpaper"
                Row {
                    id: icons
                    padding: 60
                    property var rows: (modelData.height / 100 - 1)
                    property var array: []

                    Process {
                        id: getEntriesProc
                        running: true
                        command: ["ls", Quickshell.env("HOME") + "/Desktop"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                icons.array = this.text.trim().split("\n");
                            }
                        }
                    }

                    Repeater {
                        model: Math.ceil(icons.array.length / parent.rows)
                        Column {
                            required property var modelData
                            Repeater {
                                model: icons.array.slice(modelData * icons.rows, (modelData + 1) * icons.rows)
                                MouseArea {
                                    id: desktopIcon
                                    required property var modelData
                                    height: 100
                                    width: 100
                                    hoverEnabled: true

                                    property string name
                                    property string exec
                                    property string icon: "application-default-icon"

                                    onDoubleClicked: proc1.running = true

                                    FileView {
                                        path: Quickshell.env("HOME") + "/Desktop/" + modelData
                                        onLoaded: {
                                            // Remove all desktop actions and just get a key-value set.
                                            let mainEntry = text().split(/(?:^|\n)\[.*\]\n/).map(x => x.trim())[1].split("\n");
                                            desktopIcon.name = mainEntry.find(x => x.startsWith("Name=")).slice(5);
                                            desktopIcon.exec = mainEntry.find(x => x.startsWith("Exec=")).slice(5);
                                            let icon = mainEntry.find(x => x.startsWith("Icon=")).slice(5);
                                            desktopIcon.icon = icon.length > 0 ? icon : desktopIcon.icon;
                                        }
                                    }

                                    Process {
                                        id: proc1
                                        running: false
                                        command: ["sh", "-c", desktopIcon.exec]
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        height: 72 + text1.height
                                        width: 72
                                        radius: 12
                                        color: desktopIcon.containsMouse ? "#aa7ec6d6" : "transparent"
                                        border {
                                            color: desktopIcon.containsMouse ? "#ff7ec6d6" : "transparent"
                                            width: 1
                                        }
                                        Column {
                                            padding: 4
                                            IconImage {
                                                source: Quickshell.iconPath(desktopIcon.icon)
                                                implicitSize: 64
                                            }
                                            NText {
                                                id: text1
                                                text: desktopIcon.name
                                                fontFamily: "Red Hat Display"
                                                width: 64
                                                wrapMode: Text.Wrap
                                                fontSize: 13
                                                elide: Text.ElideRight
                                                maximumLineCount: 2
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
