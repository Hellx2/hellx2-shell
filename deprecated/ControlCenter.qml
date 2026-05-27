import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import qs.common

Scope {
    id: root
    property bool showControlCenter: false
    LazyLoader {
        active: root.showControlCenter
        NWindow {
            anchorBottom: true
            anchorRight: true
            margins {
                top: 10
                right: 10
            }
            iwidth: 450
            iheight: 500
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: "#1c1c1c"
                radius: 10
                border {
                    width: 1
                    color: "#151515"
                }
            }

            ColumnLayout {
                uniformCellSizes: true
                RowLayout {
                    Layout.margins: 10
                    spacing: 20
                    uniformCellSizes: true
                    Rectangle {
                        width: 180
                        height: 180
                        radius: 10
                        color: "#2c2c2c"
                        ColumnLayout {
                            width: 180
                            anchors.centerIn: parent
                            RowLayout {
                                id: brightnessSetting
                                property int brightness: 0
                                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                                Image {
                                    source: "/usr/share/icons/Papirus/64x64/apps/brightness.svg"
                                    Layout.preferredWidth: 25
                                    Layout.preferredHeight: 25
                                }
                                Process {
                                    id: setBrightnessProc
                                    command: ["brightnessctl", "set", brightnessSetting.brightness + "%"]
                                    running: false
                                }
                                Process {
                                    id: getBrightnessProc
                                    command: ["brightnessctl", "get", "-P"]
                                    stdout: StdioCollector {
                                        onStreamFinished: brightnessSetting.brightness = this.text
                                    }
                                    running: true
                                }
                                NSlider {
                                    id: settingSlider1
                                    implicitWidth: 120
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    value: brightnessSetting.brightness

                                    onMoved: {
                                        brightnessSetting.brightness = value;
                                        setBrightnessProc.running = true;
                                    }
                                }
                            }
                            RowLayout {
                                id: volumeSetting
                                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                                PwObjectTracker {
                                    objects: Pipewire.defaultAudioSink
                                }
                                Image {
                                    source: "/usr/share/icons/Papirus/24x24/symbolic/status/audio-volume-high-symbolic.svg"
                                    Layout.preferredWidth: 25
                                    Layout.preferredHeight: 25
                                }
                                property real volume: Pipewire.defaultAudioSink.audio.volume * 100
                                NSlider {
                                    id: settingSlider2
                                    implicitWidth: 120
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                    value: volumeSetting.volume
                                    onMoved: Pipewire.defaultAudioSink.audio.volume = value / 100
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: 180
                        height: 180
                        radius: 10
                        color: "#2c2c2c"
                    }
                }
                RowLayout {
                    uniformCellSizes: true
                    Rectangle {
                        color: "red"
                    }
                }
            }
        }
    }
}
