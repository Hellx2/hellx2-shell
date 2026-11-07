import QtQuick
import qs

Text {
    id: root

    property int fontSize: Globals.theme.text_size

    property bool bold: false
    property string fontFamily: Globals.theme.text_font

    color: Globals.theme.text_fg

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        bold: root.bold
    }
}
