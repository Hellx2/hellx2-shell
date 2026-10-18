import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Widgets

import qs.common
import qs

MouseArea {
	id: root

	height: 30
	width: 30

	acceptedButtons: Qt.LeftButton | Qt.MiddleButton
	onClicked: (m) => {
		if (m.button & Qt.LeftButton) loaderActive = !loaderActive
		else {
			if (root.adapter.state == BluetoothAdapterState.Blocked) Quickshell.execDetached(["rfkill", "unblock", "bluetooth"])
			root.adapter.enabled = !root.adapter.enabled
		}
	}

	readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
	property var x1
	property bool loaderActive: false

	Rectangle {
		anchors.fill: parent
		color: (!!adapter && adapter.enabled) ? Globals.settings.accent : Globals.settings.grey4
		radius: height / 2
	}

	IconImage {
		anchors.centerIn: parent
		source: Quickshell.iconPath((!!adapter && adapter.enabled)
			? "network-bluetooth-symbolic" : "network-bluetooth-inactive-symbolic", true)
		implicitSize: 20
	}

	Connections {
		target: root.adapter
		function onStateChanged() {
			if (root.adapter.state == BluetoothAdapterState.Enabled)
				if (loader1.active) root.adapter.discovering = true
		}
	}

	LazyLoader {
		id: loader1
		active: root.loaderActive
		onActiveChanged: root.adapter.discovering = active

		PanelWindow {
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
				anchors.fill: parent
				color: Globals.settings.bgcol
				radius: 10
				border {
					width: 1
					color: Globals.settings.grey4
				}
			}
			Column {
				anchors.fill: parent
				Row {
					anchors.leftMargin: 10
					anchors.left: parent.left
					NText {
						text: root.adapter.enabled ? "Enabled" : "Disabled"
						anchors.verticalCenter: parent.verticalCenter
					}
					NSwitch {
						id: btn1
						isSwitched: root.adapter.enabled

						function timer() {
						    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
						}
						
						onIsSwitchedChanged: {
							if (root.adapter.state == BluetoothAdapterState.Blocked) Quickshell.execDetached(["rfkill", "unblock", "bluetooth"])
							root.adapter.enabled = isSwitched
						}
					}
				}
				ListView {
					id: lv
					width: parent.width - 10
					height: parent.height - btn1.height
					anchors.margins: 10
					model: ScriptModel {
						values: root.adapter.devices.values.filter(x => x.deviceName && x.deviceName != "")
							.sort((a, b) => a.paired && !b.paired ? -1 : (a.paired && b.paired ? 0 : 1))
					}
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: lv.width
							height: lv.height
							radius: 10
						}
					}
					spacing: 5
					anchors.leftMargin: 5
					anchors.left: parent.left
					delegate: Rectangle {
						required property var modelData
						required property var index

						width: lv.width
						height: 30
						radius: 10
						color: lv.currentIndex == index ? Globals.settings.grey5 : Globals.settings.grey3
						Item {
							anchors.fill: parent
							//spacing: 5
							anchors.leftMargin: 5
							anchors.rightMargin: 5
							Rectangle {
								id: icon
								width: children[0].width + 2.5
								height: children[0].height + 2.5
								radius: height / 2
								anchors.verticalCenter: parent.verticalCenter
								anchors.left: parent.left
								color: Globals.settings.grey0
								IconImage {
									//id: icon
									anchors.centerIn: parent
									source: Quickshell.iconPath(modelData.icon, true)
									implicitSize: 20
								}
							}
							Button {
								id: icon1
								padding: 1.25
								//width: contentItem.width + 2.5
								//height: children[0].height + 2.5
								anchors.verticalCenter: parent.verticalCenter
								anchors.left: icon.right
								anchors.leftMargin: 5
								background: Rectangle {
									radius: height / 2
									color: modelData.paired ? /*(icon1.hovered ? "#00aaff" : "#0077cc")*/ Globals.settings.accent : Globals.settings.grey0
								}
								contentItem: IconImage {
									source: Quickshell.iconPath("link", true)
									implicitSize: 20
								}
								onClicked: {
									if (modelData.paired) modelData.forget()
									else modelData.pair()
								}
							}
							NText {
								width: Math.min(implicitWidth, parent.width - icon.width - icon1.width - row1.implicitWidth - 15)
								elide: Text.ElideRight
								anchors.left: icon1.right
								anchors.leftMargin: 5
								anchors.verticalCenter: parent.verticalCenter
								text: modelData.deviceName
							}
							Row {
								id: row1
								anchors.verticalCenter: parent.verticalCenter
								anchors.right: parent.right
								Button {
									id: btn2
									background: Rectangle {
										radius: height / 2
										color: btn2.hovered ? "#7c7c7c" : Globals.settings.grey0
									}
									contentItem: IconImage {
										source: Quickshell.iconPath(modelData.state == BluetoothDeviceState.Connected
											? "network-bluetooth-symbolic" : "network-bluetooth-inactive-symbolic", true)
										implicitSize: 15
									}
									onClicked: {
										modelData.connected = !modelData.connected
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
