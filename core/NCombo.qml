import QtQuick
import QtQuick.Controls

import qs

Row {
	id: root
	property string label: "Value: "
	property var model: ["true", "false"]
	property bool haveNA: true
	/*property Component delegate: Text {
		color: Globals.theme.text_fg
    }*/


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
			color: Globals.theme.text_fg
			text: root.label
		}
	}
	ComboBox {
		id: combo
        model: haveNA ? ["N/A", ...root.model] : root.model
		background: Rectangle {
			implicitWidth: 120
			color: combo.hovered ? Globals.theme.active_item : Globals.theme.inactive_item
			radius: height / 4
        }
		delegate: ItemDelegate {
			width: combo.width
			contentItem: Text {
				text: modelData
				color: Globals.theme.text_fg
			}
			background: Rectangle {
				radius: 10
				color: combo.highlightedIndex == index ? Globals.theme.active_item : "transparent"
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
				color: Globals.theme.bgcol
				radius: 10
				border {
					width: 1
					color: Globals.theme.dark ? Qt.lighter(color) : Qt.darker(color)
				}
			}
		}
	}
}
