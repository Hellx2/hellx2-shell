import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.common
import qs.rootmodules

NButton {
	id: root

	property bool showMenu: false
	property bool anchorTop: false
	property bool anchorRight: true

	onClicked: root.showMenu = !root.showMenu

	height: 30
	width: 30
	bgradius: height / 2
	visible: SystemUpdater.needsUpdate
	bgcolor: hovered ? Qt.lighter(Globals.settings.accent, 1.25) : Globals.settings.accent

	contentItem: IconImage {
		source: Quickshell.iconPath("software-update-available")
		implicitSize: 25
    }

    // TODO: FINISH THIS

	LazyLoader {
		active: root.showMenu
		PanelWindow {
			implicitWidth: 400
			implicitHeight: 500
			color: "transparent"

			anchors {
				left: root.anchorRight
				right: !root.anchorRight
				top: root.anchorTop
				bottom: !root.anchorTop
			}

			margins {
				left: root.QsWindow.window.mapFromItem(root, 0, 0).x + root.QsWindow.window.margins.left + root.width / 2 - implicitWidth / 2
				right: root.QsWindow.window.mapFromItem(root, 0, 0).x + root.QsWindow.window.margins.left + root.width / 2 - implicitWidth / 2
				bottom: 10
				top: 10
			}

			Rectangle {
				anchors.fill: parent
				color: "#1c1c1c"
				radius: 10
				border {
					width: 1
					color: "#4c4c4c"
				}
			}
		}
	}
}
