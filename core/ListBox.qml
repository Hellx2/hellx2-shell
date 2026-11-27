pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets

ListView {
    id: root
    property int bgradius: 10
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
            console.warn(JSON.stringify(modelData))
            root.btnClick(JSON.stringify(modelData.data))
        }

        width: root.width
        contentItem: Row {
            spacing: 5
            IconImage {
                source: Quickshell.iconPath(nbtn.modelData?.icon || defaultIcon, true)
                implicitSize: 20
            }
            NText {
                text: `${nbtn.modelData?.text}`
            }
            NText {
                text: (nbtn.modelData?.subtext ?? "") != "" ? `(${nbtn.modelData?.subtext})` : ""
                font.italic: true
                fontSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        bgcolor: ListView.isCurrentItem ? Globals.theme.accent : (hovered ? Globals.theme.button_bg_hover : Globals.theme.button_bg)
    }
}
