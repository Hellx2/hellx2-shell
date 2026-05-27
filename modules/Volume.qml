import QtQuick
import Quickshell.Services.Pipewire
import qs.common

NButton {
    PwObjectTracker {
   	    objects: [Pipewire.defaultAudioSink]
   	}
    contentItem: Row {
        spacing: 0
        Image {
            source: "/usr/share/icons/Papirus/24x24/symbolic/status/audio-volume-" + (Pipewire.defaultAudioSink?.audio.muted ? "muted" : "high") + "-symbolic.svg"
            width: 20
            height: 20
        }
        NText {
            color: Pipewire.defaultAudioSink?.audio.muted ? "#7c7c7c" : "#ffffff"
            text: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) + "%"
        }
    }
}
