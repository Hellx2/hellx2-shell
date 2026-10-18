import QtQuick
import Quickshell.Services.Pipewire
import Quickshell
import Quickshell.Widgets
import qs.common
import qs

MouseArea {
	height: 30
	id: root
   	hoverEnabled: true
    width: (containsMouse ? 30 + txt1.width : 30)
    clip: true

    onClicked: Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink?.audio.muted
    onWheel: (m) => Pipewire.defaultAudioSink.audio.volume = Math.min(Pipewire.defaultAudioSink.audio.volume + Math.sign(m.angleDelta.y) / 100, 1)

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

	Rectangle {
		anchors.fill: parent
		color: Globals.settings.button_bg
		radius: height / 2
	}

    Row {
    	anchors.left: parent.left
    	anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        height: 20
        width: parent.width - 10
        clip: true
        IconImage {
        	source: Quickshell.iconPath("audio-volume-" + (Pipewire.defaultAudioSink?.audio.muted ? "muted" : "high") + "-symbolic", true)
            implicitSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
        NText {
        	anchors.verticalCenter: parent.verticalCenter
        	id: txt1
        	visible: root.containsMouse
            color: Pipewire.defaultAudioSink?.audio.muted ? "#9c9c9c" : "#ffffff"
            text: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) + "%"
        }
    }
    
    Behavior on width {
    	SmoothedAnimation {
    		duration: 200
    	}
    }

}
