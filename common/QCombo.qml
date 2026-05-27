import QtQuick
import QtQuick.Controls

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
			color: Styles.text_fg
			text: root.label
		}
	}
	ComboBox {
		id: combo
		model: haveNA ? ["N/A", ...root.model] : root.model
		background: Rectangle {
			implicitWidth: 120
			color: combo.hovered ? Styles.grey3 : Styles.grey0
			radius: height / 4
		}
		delegate: ItemDelegate {
			width: combo.width
			contentItem: Text {
				text: modelData
				color: Styles.text_fg
			}
			background: Rectangle {
				radius: 10
				color: combo.highlightedIndex == index ? Styles.grey3 : "transparent"
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
				color: Styles.grey0
				radius: 10
				border {
					width: 1
					color: "#1c1c1c"
				}
			}
		}
	}
}
