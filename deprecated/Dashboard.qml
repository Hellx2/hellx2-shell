import QtQuick
import Quickshell

import qs.common

Scope {
    id: root
    property bool dashboardOpen: false
    LazyLoader {
        active: root.dashboardOpen
        NWindow {
            exclusiveZone: 0
            anchorTop: true
            margins.top: 10
            iwidth: panel1.width / 3
            iheight: 400
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#3c3c3c"
                radius: 10
            }
        }
    }
}
