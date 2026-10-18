import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.common
import qs

MouseArea {
	id: root
	
	height: 30
	width: 30
	
	property bool tailscaleOn: false
	property bool showMenu: false

	Rectangle {
		anchors.fill: parent
		radius: height / 2
		color: root.tailscaleOn ? Globals.settings.accent : Globals.settings.grey4
	}
	IconImage {
		source: Quickshell.iconPath("pgp-keys", true)
		implicitSize: 22.5
		anchors.centerIn: parent
	}
	Process {
		id: getTailscaleStatus
		running: true
		command: ["tailscale", "status"]
		onExited: (c) => root.tailscaleOn = !c
	}

	acceptedButtons: Qt.MiddleButton | Qt.LeftButton

	// Only really need to check every 2 minutes, every
	// minute could work too, but it's not necessary.
	Timer {
		interval: 120000
		repeat: true
		running: true

		onTriggered: getTailscaleStatus.running = true
	}

	onClicked: e => {
		if (e.button & Qt.MiddleButton) {
			Quickshell.execDetached(["tailscale", tailscaleOn ? "down" : "up"])
			root.tailscaleOn = !root.tailscaleOn
		} else if (e.button & Qt.LeftButton) {
			showMenu = !showMenu
		}
	}

	LazyLoader {
		active: root.showMenu
		PanelWindow {
			id: mainwin
			implicitWidth: 400
			implicitHeight: 500
			anchors {
				top: root.QsWindow.window.anchors.top
				bottom: root.QsWindow.window.anchors.bottom
				left: true
			}
			margins {
				left: root.QsWindow.window.mapFromItem(root, 0, 0).x + root.QsWindow.window.margins.left + root.width / 2 - implicitWidth / 2
				bottom: 10
				top: 10
			}
			color: "transparent"
			Rectangle {
				radius: 10
				anchors.fill: parent
				color: Globals.settings.grey1
				border {
					width: 1
					color: Globals.settings.grey4
				}
			}
			Process {
				id: tailscaleDevicesProc
				running: false
				command: ["tailscale", "status", "--json"]
				stdout: StdioCollector {
					onStreamFinished: mainwin.status = JSON.parse(this.text)
				}
			}

			Timer {
				running: root.tailscaleOn
				repeat: true
				interval: 10000
				triggeredOnStart: true
				onTriggered: tailscaleDevicesProc.running = true
			}

			property var status: ({})

			Column {
				anchors.fill: parent
				spacing: 5
				Item {
					height: 25
					width: parent.width
					NText {
						text: "Tailscale"
						anchors.horizontalCenter: parent.horizontalCenter
						font {
							pixelSize: 18
							family: "Red Hat Display"
							underline: true
						}
					}
					NSwitch {
						id: switch1
						anchors.right: parent.right
						isSwitched: root.tailscaleOn
						onIsSwitchedChanged: {
							Quickshell.execDetached(["tailscale", isSwitched ? "up" : "down"])
							root.tailscaleOn = isSwitched
						}
					}
				}
				NText {
					text: "Users"
					anchors.horizontalCenter: parent.horizontalCenter
					font {
						pixelSize: 16
						family: "Red Hat Display"
						underline: true
					}
				}
				Rectangle {
					height: 200
					width: parent.width - 20
					anchors.horizontalCenter: parent.horizontalCenter
					radius: 15
					color: Globals.settings.grey2
					border {
						width: 1
						color: Globals.settings.grey4
					}
					ListView {
						anchors.fill: parent
						anchors.margins: 1
						id: lv1
						visible: root.tailscaleOn
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: lv1.width
								height: lv1.height
								radius: 15
							}
						}
						spacing: 5
						model: !!status?.User && Object.values(status?.User).filter(x => x.LoginName != "tagged-devices") || []
						delegate: Rectangle {
							width: lv1.width
							anchors.horizontalCenter: parent.horizontalCenter
							height: 30
							color: Globals.settings.grey3
							radius: height / 2
							Row {
								anchors.left: parent.left
								anchors.leftMargin: 5
								spacing: 5
								anchors.verticalCenter: parent.verticalCenter
								width: parent.width / 3 - 5
								IconImage {
									layer.enabled: true
									layer.effect: OpacityMask {
										maskSource: Rectangle {
											width: 20
											height: 20
											radius: height / 2
										}
									}
									anchors.verticalCenter: parent.verticalCenter
									source: modelData.ProfilePicURL || ""
									implicitSize: 20
								}
								NText {
									width: parent.width - 25
									elide: Text.ElideRight
									anchors.verticalCenter: parent.verticalCenter
									//text: `${modelData.HostName} [${modelData.OS}] ${modelData.Active ? "" : "in"}active o${modelData.Online ? "n" : "ff"}line`
									text: modelData.DisplayName
									bold: true
								}
							}
								
							NText {
								anchors.verticalCenter: parent.verticalCenter
								anchors.rightMargin: 5
								anchors.right: parent.right
								width: parent.width * 2 / 3 - 10
								elide: Text.ElideRight
								text: modelData.LoginName
							}
						}
					}
				}
				NText {
					text: "Devices"
					anchors.horizontalCenter: parent.horizontalCenter
					font {
						pixelSize: 16
						family: "Red Hat Display"
						underline: true
					}
				}
				Rectangle {
					height: 200
					width: parent.width - 20
					anchors.horizontalCenter: parent.horizontalCenter
					radius: 15
					color: Globals.settings.grey2
					border {
						width: 1
						color: Globals.settings.grey4
					}
					ListView {
						anchors.fill: parent
						anchors.margins: 1
						id: lv
						visible: root.tailscaleOn
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: lv.width
								height: lv.height
								radius: 15
							}
						}
						spacing: 5
						model: ScriptModel {
							values: !!status?.Peer && Object.values(status?.Peer).sort((a, b) => a.Active ? (b.Active ? 0 : -1) : 1) || []
						}
						delegate: Rectangle {
							width: lv.width
							anchors.horizontalCenter: parent.horizontalCenter
							height: 30
							color: Globals.settings.grey3
							radius: height / 2
							Row {
								anchors.left: parent.left
								anchors.leftMargin: 5
								width: parent.width - rightrow.width - 15
								spacing: 5
								anchors.verticalCenter: parent.verticalCenter
								IconImage {
									anchors.verticalCenter: parent.verticalCenter
									source: Quickshell.iconPath(({
										"linux": "tux",
										"windows": "microsoft",
										"android": "distributor-logo-android"
									})[modelData.OS], true)
									implicitSize: 20
								}
								NText {
									anchors.verticalCenter: parent.verticalCenter
									//text: `${modelData.HostName} [${modelData.OS}] ${modelData.Active ? "" : "in"}active o${modelData.Online ? "n" : "ff"}line`
									text: modelData.HostName
								}
							}
							Row {
								anchors.right: parent.right
								anchors.rightMargin: 5
								spacing: 5
								anchors.verticalCenter: parent.verticalCenter
								id: rightrow
								NText {
									text: modelData.TailscaleIPs[0]
									anchors.verticalCenter: parent.verticalCenter
									bold: true
								}
								Rectangle {
									width: 25
									height: 25
									radius: height / 2 
									color: Globals.settings.grey1

									IconImage {
										anchors.centerIn: parent
										source: Quickshell.iconPath(modelData.Online ? "network-wireless" : "network-disconnected")
										implicitSize: 20
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
