pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets

ListView {
    id: root
    property int bgradius: 10
    property int iconSize: 20
    property int fontSize: 13
    spacing: 5

    property var defaultIcon: ""

    signal btnClick(data: string)

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.bgradius
        }
    }

    keyNavigationEnabled: true

    delegate: NButton {
        id: nbtn
        required property var modelData
        required property var index
        bgradius: 5
        onClicked: root.currentIndex = index
        onDoubleClicked: {
            console.warn(JSON.stringify(modelData));
            root.btnClick(JSON.stringify(modelData.data));
        }

        width: root.width
        contentItem: Row {
            spacing: iconSize / 4
            IconImage {
                source: Quickshell.iconPath(nbtn.modelData?.icon || root.defaultIcon, true)
                implicitSize: root.iconSize
            }
            NText {
                anchors.verticalCenter: parent.verticalCenter
                text: `${nbtn.modelData?.text}`
                fontSize: root.fontSize
            }
            NText {
                anchors.verticalCenter: parent.verticalCenter
                text: (nbtn.modelData?.subtext ?? "") != "" ? `(${nbtn.modelData?.subtext})` : ""
                font.italic: true
                fontSize: 12
            }
        }
        bgcolor: ListView.isCurrentItem ? Globals.theme.accent : (hovered ? Globals.theme.button_bg_hover : Globals.theme.button_bg)
    }
}
