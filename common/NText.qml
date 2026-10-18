import QtQuick
import qs

Text {
    id: root

    property int fontSize: Globals.settings.text_size

    property bool bold: false
    property string fontFamily: Globals.settings.text_font

    color: Globals.settings.text_fg

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        bold: root.bold
    }
}
