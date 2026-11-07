import QtQuick
import Quickshell.Services.Pipewire
import Quickshell
import Quickshell.Widgets
import qs.core
import qs

MouseArea {
    id: root
    height: 30
    hoverEnabled: true
    width: (containsMouse ? 30 + txt1.width + 5 : 30)
    clip: true

    onClicked: Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink?.audio.muted
    onWheel: m => Pipewire.defaultAudioSink.audio.volume = Math.min(Pipewire.defaultAudioSink.audio.volume + Math.sign(m.angleDelta.y) / 100, 1)

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Rectangle {
        anchors.fill: parent
        color: Globals.theme.button_bg
        radius: height / 2
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        height: 20
        width: parent.width - 10
        clip: true
        IconImage {
            source: Quickshell.iconPath("audio-volume-" + (Pipewire.defaultAudioSink?.audio.muted ? "muted" : "high") + "-symbolic", true)
            implicitSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
        NText {
            id: txt1
            anchors.verticalCenter: parent.verticalCenter
            visible: root.containsMouse
            color: Pipewire.defaultAudioSink?.audio.muted ? Globals.theme.inactive_item : Globals.theme.text_fg
            text: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) + "%"
        }
    }

    Behavior on width {
        SmoothedAnimation {
            duration: 200
        }
    }
}
