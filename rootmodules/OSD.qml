pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Widgets

import qs.common

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // None = 0, Brightness = 1, Player = 2, PlayerNext = 3, PlayerPrev = 4, Volume = 5
    property int currentOsd: 0

    property string setBrightnessTo: "50%"
    property var currentBrightness: 50
    property bool isPlaying: false

    // Delay to allow Pipewire time to initialise
    Timer {
        running: true
        repeat: false
        interval: 100
        onTriggered: root.loaderActive = true
    }

    property bool loaderActive: false
    LazyLoader {
        active: root.loaderActive
        Loader {
            sourceComponent: Item {
                id: sourceComponent

                IpcHandler {
                    function playPause() {
                        Mpris.players.values[0].togglePlaying()
                        root.currentOsd = 2; // Player
                        hideTimer.restart();
                    }
                    function next() {
                        if (Mpris.players.values[0].canGoNext) {
                            Mpris.players.values[0].next();
                            root.currentOsd = 3; // PlayerNext
                            hideTimer.restart();
                        }
                    }
                    function prev() {
                        if (Mpris.players.values[0].canGoPrevious) {
                            Mpris.players.values[0].previous();
                            root.currentOsd = 4; // PlayerPrev
                            hideTimer.restart();
                        }
                    }
                    target: "players"
                }
                Connections {
                    target: Pipewire.defaultAudioSink?.audio

                    function onVolumeChanged() {
                        root.currentOsd = 5; //Player
                        hideTimer.restart();
                    }

                    function onMutedChanged() {
                        root.currentOsd = 5; //Player
                        hideTimer.restart();
                    }
                }

                Process {
                    id: setBrightnessProc
                    command: ["fish", "-c", `brightnessctl s ${setBrightnessTo} &>/dev/null; math "$(brightnessctl g)/$(brightnessctl m)*100"`]

                    running: false

                    stdout: StdioCollector {
                        onStreamFinished: {
                            root.currentBrightness = Number(this.text);
                            root.currentOsd = 1; // Brightness
                            hideTimer.restart();
                        }
                    }
                }

                IpcHandler {
                    function set(brightness: string) {
                        root.setBrightnessTo = brightness;
                        setBrightnessProc.running = true;
                    }
                    target: "brightness"
                }

                Timer {
                    id: hideTimer
                    interval: 1000
                    onTriggered: {
                        root.currentOsd = 0;
                    }
                }

                LazyLoader {
                    active: root.currentOsd == 5 || root.currentOsd == 1 // Volume or Brightness OSD

                    PanelWindow {
                    	WlrLayershell.layer: WlrLayer.Overlay
                    	screen: Data.getPrimaryScreen()
                        anchors.bottom: true
                        margins.bottom: screen.height / 5
                        exclusiveZone: 0

                        implicitWidth: 400
                        implicitHeight: 50

                        color: "transparent"

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: '#ff000000'

                            Row {
                                width: parent.width - 25
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 10
                                    rightMargin: 15
                                }

                                Image {
                                    width: 30
                                    height: 30
                                    source: root.currentOsd == 5 ? ("/usr/share/icons/Papirus/24x24/symbolic/status/audio-volume-" + (Pipewire.defaultAudioSink?.audio.muted ?? true ? "muted" : "high") + "-symbolic.svg") : "/usr/share/icons/Papirus/64x64/apps/brightness.svg"
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - parent.children[0].width - parent.spacing

                                    height: 10
                                    radius: 20
                                    color: "#60ffffff"

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }

                                        color: root.currentOsd == 5 ? (Pipewire.defaultAudioSink?.audio.muted ?? true ? "#3c3c3c" : "#3399ff") : "#3399ff"

                                        width: parent.width * (root.currentOsd == 5 ? Pipewire.defaultAudioSink?.audio.volume ?? 0 : root.currentBrightness / 100)
                                        radius: parent.radius
                                    }
                                }
                            }
                        }
                    }
                }
                LazyLoader {
                    active: root.currentOsd == 2 || root.currentOsd == 3 || root.currentOsd == 4 // PlayerNext || PlayerPrev

                    PanelWindow {
                        anchors.bottom: true
                        margins.bottom: screen.height / 5
                        exclusiveZone: 0
                        implicitWidth: 400
                        implicitHeight: 50
                        color: "transparent"

                        Rectangle {
                            anchors.fill: parent
                            color: Styles.grey1
                            border {
                            	width: 1
                            	color: Styles.grey3
                            }
                            radius: height / 2
                            Row {
                            	anchors.fill: parent
                            	spacing: 10
                            	anchors.leftMargin: 20
                            	anchors.rightMargin: 20
	                            NText {
   	                            	anchors.verticalCenter: parent.verticalCenter
	                                fontSize: root.currentOsd == 2 ? (Mpris.players.values[0].isPlaying ? 25 : 30) : 30
	                                width: 20
	                                horizontalAlignment: Text.AlignHCenter
	                                text: root.currentOsd == 2 ? (Mpris.players.values[0].isPlaying ? "▶" : "⏸") : (root.currentOsd == 3 ? "⇥" : "⇤")
	                            }
                                IconImage {
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: Quickshell.iconPath(DesktopEntries.byId(Mpris.players.values[0].desktopEntry)?.icon, true)
                                    implicitSize: 25
                                }
	                            NText {
	                            	anchors.verticalCenter: parent.verticalCenter
	                            	fontSize: 16
	                            	text: (Mpris.players.values[0].trackTitle || "Unknown")
	                            }
                            }
                        }
                    }
                }
            }
        }
    }
}
