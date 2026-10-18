import QtQuick
import QtQuick.Controls

import qs

Row {
	id: root
	property string label: "Value: "
	property var model: ["true", "false"]
	property bool haveNA: true
	property Component delegate: Text {
		color: "#ffffff"
	}


	function value() {
		return combo.currentValue != "N/A" ? combo.currentValue : null
	}

	function reset() {
		combo.currentValue = "N/A"
	}

	Row {
		height: 30
		Text {
			anchors.verticalCenter: parent.verticalCenter
			color: Globals.settings.text_fg
			text: root.label
		}
	}
	ComboBox {
		id: combo
		model: haveNA ? ["N/A", ...root.model] : root.model
		background: Rectangle {
			implicitWidth: 120
			color: combo.hovered ? Globals.settings.grey3 : Globals.settings.grey0
			radius: height / 4
		}
		delegate: ItemDelegate {
			width: combo.width
			contentItem: Text {
				text: modelData
				color: Globals.settings.text_fg
			}
			background: Rectangle {
				radius: 10
				color: combo.highlightedIndex == index ? Globals.settings.grey3 : "transparent"
			}
		}
		popup: Popup {
			width: combo.width
			implicitHeight: contentItem.implicitHeight

			contentItem: ListView {
				id: lv
				implicitHeight: contentHeight
				model: combo.delegateModel
				clip: true

				ScrollIndicator.vertical: ScrollIndicator { }
			}

			padding: 0

			background: Rectangle {
				color: Globals.settings.grey0
				radius: 10
				border {
					width: 1
					color: "#1c1c1c"
				}
			}
		}
	}
}
