import QtQuick
import QtQuick.Controls

TextField {
    id: root

    property string bgcolor: Styles.input_bg
    property string fgcolor: Styles.text_fg
    // Placeholder colour
    property string fontFamily: Styles.text_font

    property int bgradius: Styles.input_radius
    property int fontSize: Styles.input_text_size

    verticalAlignment: Text.AlignVCenter
    padding: 0

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
