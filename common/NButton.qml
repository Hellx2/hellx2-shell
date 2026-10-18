import QtQuick
import QtQuick.Controls
import Quickshell

import qs

Button {
    id: root
    property string content: ""
    property string bgcolor: down ? Globals.settings.button_bg_down : (hovered ? Globals.settings.button_bg_hover : Globals.settings.button_bg)
    property string fgcolor: Globals.settings.text_fg
    property int bgradius: height / 2
    property bool bold: false
    property int sidePad: Globals.settings.button_sidepad
    property var elide: Text.ElideNone

    contentItem: NText {
        leftPadding: root.sidePad
        rightPadding: root.sidePad
        text: root.content
        color: root.fgcolor
        bold: root.bold
        elide: root.elide
    }
    background: Rectangle {
        color: root.bgcolor
        radius: root.bgradius
    }
}
