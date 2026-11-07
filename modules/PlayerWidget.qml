import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.core
import qs

NButton {
    visible: !!Mpris.players.values[0]
    onClicked: Mpris.players.values[0].togglePlaying()
    height: 30
    bgcolor: Mpris.players.values[0]?.isPlaying ? (hovered ? Qt.lighter(Globals.theme.accent, 1.3) : Globals.theme.accent) : (hovered ? Globals.theme.button_bg_hover : Globals.theme.button_bg)
    contentItem: Row {
        leftPadding: 2.5
        rightPadding: 2.5
        spacing: 7.5
        NText {
            anchors.verticalCenter: parent.verticalCenter
            fontSize: Mpris.players.values[0]?.isPlaying ? 16 : 19.2
            horizontalAlignment: Text.AlignHCenter
            text: (Mpris.players.values[0]?.isPlaying ? "▶" : "⏸")
        }
        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(DesktopEntries.byId(Mpris.players.values[0]?.desktopEntry)?.icon, true)
            implicitSize: 20
        }
        NText {
            width: Math.min(implicitWidth, 200)
            anchors.verticalCenter: parent.verticalCenter
            text: (Mpris.players.values[0]?.trackArtist != "" ? Mpris.players.values[0]?.trackArtist + " - " : "") + (Mpris.players.values[0]?.trackTitle || "Unknown Track")
            elide: Text.ElideRight
        }
    }
}
