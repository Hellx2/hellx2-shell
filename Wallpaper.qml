import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtCore

PanelWindow {
	id: root
	implicitWidth: screen.width
	implicitHeight: screen.height
	WlrLayershell.layer: WlrLayer.Background
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.namespace: "wallpaper"
	color: "transparent"

	property string backgroundPath: Quickshell.env("HOME") + "/.local/share/wallpaper.jpg"

	Settings {
		property alias backgroundPath: root.backgroundPath
	}

	IpcHandler {
		target: "wallpaper"
		function set(path: string) {
			root.backgroundPath = path
		}
	}

	AnimatedImage {
		id: mainImage
		asynchronous: true
		cache: true
		onStatusChanged: playing = (status == AnimatedImage.Ready)
		anchors.fill: parent
		source: root.backgroundPath
		fillMode: Image.PreserveAspectCrop
	}
}
