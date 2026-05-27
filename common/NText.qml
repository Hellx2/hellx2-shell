import QtQuick

Text {
    id: root

    property int fontSize: Styles.text_size

    property bool bold: false
    property string fontFamily: Styles.text_font

    color: Styles.text_fg

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        bold: root.bold
    }
}
