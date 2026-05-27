import QtQuick
import QtQuick.Controls

Button {
    id: root
    property string content: ""
    property string bgcolor: down ? Styles.button_bg_down : (hovered ? Styles.button_bg_hover : Styles.button_bg)
    property string fgcolor: Styles.text_fg
    property int bgradius: height / 2
    property bool bold: false

    contentItem: NText {
        leftPadding: 2.5
        rightPadding: 2.5
        text: root.content
        color: root.fgcolor
        bold: root.bold
    }
    background: Rectangle {
        color: root.bgcolor
        radius: root.bgradius
    }
}
