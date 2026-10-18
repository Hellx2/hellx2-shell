import QtQuick
import QtQuick.Controls
import qs

TextField {
    id: root

    property string bgcolor: Globals.settings.input_bg
    property string fgcolor: Globals.settings.text_fg
    // Placeholder colour
    property string fontFamily: Globals.settings.text_font

    property int bgradius: Globals.settings.input_radius
    property int fontSize: Globals.settings.input_text_size

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
