import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.common

Scope {
    id: root
    property var currentNotifications: []
    Timer {
        id: clearTimer
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            for (let i of root.currentNotifications)
                i?.expire()
            root.currentNotifications = []
        }
    }

    function clear(notification) {
        currentNotifications.splice(currentNotifications.indexOf(notification), 1)
    }

    onCurrentNotificationsChanged: {
        if (currentNotifications.length > 5) {
            currentNotifications.shift()
        }
        if (currentNotifications.length > 0) {
            clearTimer.restart()
        }
    }

    NotificationServer {
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        onNotification: a => {
            a.tracked = true
            root.currentNotifications.push(a)
            root.currentNotificationsChanged()
        }
    }

    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins {
            top: 10
            right: 10
        }
        color: "transparent"
        implicitWidth: 450
        implicitHeight: mainColumn.children.reduce((a, b) => !(a instanceof Repeater) ? a + b.height + 10 : a, 0) - 10
        visible: root.currentNotifications.length > 0
        Column {
            id: mainColumn
            width: parent.width
            spacing: 10
            Repeater {
                model: root.currentNotifications
                delegate: MouseArea {
                    required property var modelData
                    id: mouse1
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    function close() {
                        if (modelData.tracked) modelData.tracked = false
                    }
                    Connections {
                        target: modelData
                        function onClosed() {
                            visible = false
                            root.clear(modelData)
                        }
                    }
                    onClicked: m => {
                        if (m.button == Qt.RightButton) {
                            close()
                        }
                    }
                    height: text1.height + text2.height + text3.height + 20 + (row1.visible ? row1.height : 0)
                    width: parent.width
                    Rectangle {
                        color: "#1c1c1c"
                        border {
                            width: 1
                            color: "#3c3c3c"
                        }
                        radius: 5
                        width: parent.width
                        height: parent.height

                        Item {
                            anchors.fill: parent
                            Item {
                                width: parent.width
                                id: mainItem
                                height: Math.max(icon.height, text1.height + text2.height + text3.height + 20)
                                IconImage {
                                    id: icon
                                    source: modelData.image
                                    implicitSize: modelData.image == "" ? 0 : 100
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    anchors.margins: 10
                                    anchors.left: icon.right
                                    anchors.top: parent.top
                                    width: parent.width - icon.width - 20
                                    id: col1
                                    NText {
                                        id: text1
                                        text: modelData.appName.toUpperCase()
                                        color: "#cccccc"
                                        fontSize: 13
                                    }
                                    NText {
                                        id: text2
                                        text: modelData.summary
                                        bold: true
                                        fontSize: 17
                                    }
                                    NText {
                                        id: text3
                                        text: modelData.body
                                        fontSize: 15
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 5
                                    }
                                }
                            }
                            Grid {
                                columns: 2
                                id: row1
                                anchors.top: mainItem.bottom
                                height: Math.ceil(modelData.actions.length / 2) * 35
                                visible: modelData.actions.length > 0
                                width: parent.width
                                Repeater {
                                    model: modelData.actions
                                    NButton {
                                        width: parent.width / 2
                                        required property var modelData
                                        content: modelData.text
                                        onClicked: {
                                            modelData.invoke()
                                            if (mouse1.modelData && !mouse1.modelData.resident) mouse1.close()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
