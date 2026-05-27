import Quickshell
import QtQuick

import qs.common

PanelWindow {
	id: root
	property var bgcolor: Styles.bgcol
	property bool fillWidth: true
	property bool topOfScreen: false

	property int padHorizontal: 20
	property int padVertical: 10

	property int radius: 15

	implicitHeight: 40
	color: "transparent"

	anchors {
		left: root.fillWidth
		right: root.fillWidth
		top: root.topOfScreen
		bottom: !root.topOfScreen
	}

	margins {
		bottom: root.topOfScreen ? 0 : root.padVertical
		top: 	root.topOfScreen ? root.padVertical : 0
		left:   root.fillWidth ? root.padHorizontal : 0
		right:  root.fillWidth ? root.padHorizontal : 0
	}

	Rectangle {
		anchors.fill: parent
		color: root.bgcolor
		radius: root.radius
	}
}
