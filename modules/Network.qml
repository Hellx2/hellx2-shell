import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs

MouseArea {
	id: root

	property var x1
	property bool showWindow: false
	property var mainDevice: Networking.devices.values.find(x => x instanceof WifiDevice)
	property var networks: []

	width: parent.height
	height: parent.height
	hoverEnabled: true
	acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: (m) => {
		if (m.button & Qt.LeftButton) mainDevice.scannerEnabled = showWindow = !showWindow
		else Networking.wifiEnabled = !Networking.wifiEnabled
	}

	Process {
		id: networksProc
		command: ["nmcli", "-c", "no", "-g", "in-use,bssid,ssid,signal", "device", "wifi", "list", "ifname", root.mainDevice.name]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				root.networks = Object.values(this.text.trim().split("\n").map(x => x.replace(/\\:/g, ";").split(":")
					.map(x => x.replace(/;/g, ":")))
					.map(x => ({connected: x[0] == "*", bssid: x[1], ssid: x[2], signal: x[3] }))
					.reduce((acc, cur) => {
						if(acc[cur.ssid] == undefined) acc[cur.ssid] = cur
						else {
							acc[cur.ssid].connected = acc[cur.ssid].connected || cur.connected
							acc[cur.ssid].signal = Math.max(acc[cur.ssid].signal, cur.signal)
						}
						return acc
					}, {} ) )
					.filter(x => x.bssid != "" && x.bssid != undefined && x.ssid != "" && x.ssid != undefined)
					.sort((a, b) => a.connected && !b.connected ? -1 : (!a.connected && b.connected ? 1: (a.signal < b.signal ? 1 : (a.signal > b.signal ? -1 : 0))))
			}
		}
	}
	Rectangle {
		anchors.fill: parent
		radius: height / 2
		color: Networking.wifiEnabled ? Globals.settings.accent : Globals.settings.grey4

		IconImage {
			anchors.centerIn: parent
			source: Quickshell.iconPath(Networking.wifiEnabled ?
				(root.mainDevice?.state == ConnectionState.Connected ? "nm-signal-" + (Math.round(root.mainDevice.networks.values[0]?.signalStrength * 4) * 25)
					: (root.mainDevice?.state == ConnectionState.Connecting ? "nm-stage01-connecting01" : "nm-no-connection-symbolic"))
				: "nm-no-connection-symbolic", true)
			implicitSize: parent.height * 0.8
		}
	}
	property string wifiToConnectTo: ""

	Process {
		id: connectToWifi
		command: ["nmcli", "device", "wifi", "connect", root.wifiToConnectTo, "ifname", root.mainDevice.name]
		stderr: StdioCollector {
			onStreamFinished: {
				// TODO: Add secret checking
				console.warn(this.text)
			}
		} 
	}

	LazyLoader {
		active: root.showWindow
		PanelWindow {
			implicitHeight: 500
			implicitWidth: 400
			anchors {
				top: root.QsWindow.window.anchors.top
				bottom: root.QsWindow.window.anchors.bottom
				left: true
			}
			/*Timer {
				running: Networking.wifiEnabled
				repeat: true
				interval: 5000
				onTriggered: networksProc.running = true
            }*/
			margins {
				left: root.QsWindow.window.mapFromItem(root, 0, 0).x + root.QsWindow.window.margins.left + root.width / 2 - implicitWidth / 2
				bottom: 10
				top: 10
			}
			color: "transparent"
			Rectangle {
				anchors.fill: parent
				color: Globals.settings.bgcol
				radius: 10
				border {
					width: 1
					color: "#3c3c3c"
				}
			}
			Column {
				anchors.fill: parent
				anchors.margins: 5
				spacing: 5
				Row {
					id: toprow
					anchors.leftMargin: 5
					anchors.left: parent.left
					NText {
						anchors.verticalCenter: parent.verticalCenter
						text: Networking.wifiEnabled ? "Enabled" : "Disabled"
					}
					NSwitch {
						anchors.verticalCenter: parent.verticalCenter
						isSwitched: Networking.wifiEnabled
						onIsSwitchedChanged: {
							Networking.wifiEnabled = this.isSwitched
							//root.networks = []
							//if (isSwitched) networksProc.running = true
						}
					}
				}
				ListView {
					id: lv
					visible: Networking.wifiEnabled
					model: root.mainDevice.networks
					height: parent.height - toprow.height - 5
					width: parent.width
					spacing: 5
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: lv.width
							height: lv.height
							radius: 10
						}
					}
					
					delegate: Row {
						required property var modelData
						required property var index
						
						width: lv.width
						Rectangle {
							height: 27.5
							width: parent.width
							radius: 10
							color: modelData.connected ? Globals.settings.grey6 : Globals.settings.grey3

							Row {
								height: parent.height
								width: parent.width - rightrow.width - 10
								anchors.left: parent.left
								anchors.leftMargin: 5
								spacing: 5
								Button {
									id: icon1
									padding: 1.25
									anchors.verticalCenter: parent.verticalCenter
									background: Rectangle {
										radius: height / 2
										color: modelData.connected ? Globals.settings.accent : Globals.settings.grey0
									}
									contentItem: IconImage {
										anchors.centerIn: parent
                                        source: {
                                            //console.warn(Math.round(modelData.signalStrength * 4) * 25)
                                            Quickshell.iconPath("nm-signal-" + (Math.round(modelData.signalStrength * 4) * 25), true)
                                        }
										implicitSize: 20
										anchors.verticalCenter: parent.verticalCenter
									}
									onClicked: {
										if (modelData.connected)
											//Quickshell.execDetached(["nmcli", "connection", "down", modelData.ssid])
											root.mainDevice.disconnect()
										else {
											//root.wifiToConnectTo = modelData.bssid
                                            //connectToWifi.running = true
                                            modelData.connect()
										}
										//networksProc.running = true
										//if (modelData.paired) modelData.forget()
										//else modelData.pair()
									}
								}
								NText {
									anchors.verticalCenter: parent.verticalCenter
									width: parent.width - icon1.width - 5
									elide: Text.ElideRight
									text: `${modelData.name}`
								}
							}
							Row {
								id: rightrow
								anchors.right: parent.right
								anchors.rightMargin: 5
								anchors.verticalCenter: parent.verticalCenter
								NText {
									text: `(${Math.round(modelData.signalStrength * 100)}%)`
								}
							}
						}
					}
				}
			}
		}
	}
}
