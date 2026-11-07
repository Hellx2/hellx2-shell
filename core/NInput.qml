import QtQuick
import QtQuick.Controls
import qs

TextField {
    id: root

    property string bgcolor: Globals.theme.input_bg
    property string fgcolor: Globals.theme.text_fg
    // Placeholder colour
    property string fontFamily: Globals.theme.text_font

    property int bgradius: Globals.theme.input_radius
    property int fontSize: Globals.theme.input_text_size

    verticalAlignment: Text.AlignVCenter
    padding: 0
    color: fgcolor

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        bold: true
    }

    background: Rectangle {
        color: root.bgcolor
        radius: root.bgradius
    }
}
