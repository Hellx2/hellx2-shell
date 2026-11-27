import QtQuick
import QtQuick.Shapes
import Quickshell

MouseArea {
    id: root
    property string content: ""
    property bool hoverEnabled: true
    property string bgcolor: pressed ? Globals.theme.button_bg_down : (containsMouse ? Globals.theme.button_bg_hover : Globals.theme.button_bg)
    property string fgcolor: Globals.theme.text_fg
    property int bgradius: height / 2
    property bool bold: false
    property int sidePad: Globals.theme.button_sidepad
    property var elide: Text.ElideNone
    property var shapeData: []
    width: row1.width + 10
    height: 30
    Rectangle {
        anchors.fill: parent
        color: root.bgcolor
        radius: root.bgradius
    }

    Row {
        id: row1
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5
        width: (txt1.visible ? txt1.width + 5 : 0) + (root.shapeData.length > 0 ? 20 : 0)
        height: 30
        Shape {
            layer.enabled: true
            layer.samples: 5
            visible: root.shapeData.length > 0
            width: 20
            height: 20
            data: root.shapeData
            anchors.verticalCenter: parent.verticalCenter
        }
        NText {
            id: txt1
            visible: root.content != ""
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: root.sidePad
            rightPadding: root.sidePad
            text: root.content
            color: root.fgcolor
            bold: root.bold
            elide: root.elide
        }
    }
}
