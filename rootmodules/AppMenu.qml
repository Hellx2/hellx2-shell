pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtCore
import qs.common
import qs

Singleton {
    id: root
    property bool showAppMenu: false
    // For some reason, settings objects can't really store
    // anything other than primitive types like numbers and
    // strings, so this has to be converted between a JSON
    // string and an object constantly.
    property var history: '{"audacity": 1}'

    Settings {
        id: settings
        property alias history: root.history
    }

    property var model: [...DesktopEntries.applications.values]

    IpcHandler {
        function toggle() {
            root.showAppMenu = !root.showAppMenu;
        }
        function open() {
            root.showAppMenu = true;
        }
        function close() {
            root.showAppMenu = false;
        }
        target: "apps"
    }
    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            if (ToplevelManager.activeToplevel != null) root.showAppMenu = false
        }
    }
    property var x: 20
    property var y: 20
    function run(entry) {
        let hist = JSON.parse(history)
        if (!!hist[entry.id]) hist[entry.id] += 1
        else hist[entry.id] = 1
        // settings.sync()
        history = JSON.stringify(hist)

        Quickshell.execDetached(entry.command);
        showAppMenu = false;
    }
    PanelWindow {
        id: mainwin
        visible: root.showAppMenu
        onVisibleChanged: {
            mainInput.text = "";
            lv.currentIndex = 0;
            mainInput.focus = true;
        }
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        implicitWidth: 500
        implicitHeight: 500

        anchors {
            left: true
            bottom: true
        }
        margins {
            left: root.x
            bottom: root.y
        }

        color: "transparent"
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#1c1c1c"
            opacity: 0.8
            border {
                width: 1
                color: "#2c2c2c"
            }
        }

        Column {            
            width: parent.width - 2
            height: parent.height - 2
            anchors.centerIn: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: mainwin.width
                    height: mainwin.height
                    radius: 10
                }
            }
            Row {
                id: topRow
                height: 50
                width: parent.width - 5
                anchors.left: parent.left
                anchors.leftMargin: 5
                spacing: 5
                /*Shape {
					layer.enabled: true
					layer.samples: 5
                    width: parent.height * 5 / 8
                    height: parent.height
                    	ShapePath {
                           id: path1
                           strokeColor: Globals.settings.white
                           fillColor: Globals.settings.white
                           startX: topRow.height * 4 / 16; startY: topRow.height * 6 / 16
                           PathLine { x: topRow.height * 15 / 32; y: topRow.height * 8 / 16 }
                           PathLine { x: topRow.height * 4 / 16; y: topRow.height * 10 / 16 }
                           PathLine { x: topRow.height * 4 / 16; y: topRow.height * 6 / 16 }
                       }
                }*/
                IconImage {
                    source: Quickshell.iconPath("edit-find", true)
                    implicitSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                NInput {
                	bgcolor: "transparent"
                    id: mainInput
                    focus: true
                    font.bold: false
                    width: parent.width - 30
                    fontSize: 18
                    height: parent.height
                    Keys.onDownPressed: lv.incrementCurrentIndex()
                    Keys.onUpPressed: lv.decrementCurrentIndex()
                    Keys.onEscapePressed: root.showAppMenu = false
                    font.family: "Red Hat Display"

                    onAccepted: root.run(lv.model.values[lv.currentIndex])
                }
            }
            Row {
                height: parent.height - 55
                width: parent.width - 10
                anchors.bottomMargin: 5
                spacing: 7.5
                anchors.horizontalCenter: parent.horizontalCenter
                ListView {
                    id: lv
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: lv.width
                            height: lv.height
                            radius: 10
                        }
                    }
                    width: parent.width * 5 / 8 - 5
                    height: parent.height
                    model: ScriptModel {
                        values: root.model.sort((a, b) => {
                            let hist = JSON.parse(root.history)
                            //root.history.forEach(x => hist[x[0]] = x[1])
                            let A = a.name.toUpperCase();
                            let B = b.name.toUpperCase();
                            let tmp = ((a, b) => {
                                let rv = (!!hist[a.id] && (!hist[b.id] || (hist[a.id] > hist[b.id])))
                                ? -1 : (!!hist[b.id] && (!hist[a.id] || hist[b.id] > hist[a.id]) ? 1 : 0)
                                return rv
                            })(a, b)
                            if (tmp != 0) return tmp
                            if (A < B)
                                return -1;
                            else if (A > B)
                                return 1;
                            return 0;
                        }).filter(x => x.id.toLowerCase().includes(mainInput.text.toLowerCase())
                                                  || x.name.toLowerCase().includes(mainInput.text.toLowerCase()))
                        onValuesChanged: lv.currentIndex = 0
                    }
                    keyNavigationEnabled: true
                    delegate: NButton {
                        required property var modelData
                        required property var index
                        width: lv.width
                        bgradius: 0
                        background: Rectangle {
                            topRightRadius: index == 0 ? 10 : 0
                            topLeftRadius: index == 0 ? 10 : 0
                            bottomRightRadius: index == lv.count - 1 ? 10 : 0
                            bottomLeftRadius: index == lv.count - 1 ? 10 : 0
                            color: parent.ListView.isCurrentItem ? /*"#5c77aa"*/ Globals.settings.accent : (parent.hovered ? Globals.settings.button_bg_hover : Globals.settings.button_bg)
                        }
                        onClicked: lv.currentIndex = index
                        onDoubleClicked: root.run(modelData)
                        contentItem: Row {
                            spacing: 5
                            IconImage {
                                source: Quickshell.iconPath(modelData.icon, true)
                                implicitSize: 20
                            }
                            NText {
                                text: `${modelData?.name}`
                            }
                            NText {
                                text: modelData.genericName != "" ? `(${modelData.genericName})` : ""
                                font.italic: true
                                fontSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
                Rectangle {
                    height: parent.height
                    width: parent.width * 3 / 8 - 5
                    radius: 10
                    border {
                        width: 1
                        color: "#2c2c2c"
                    }
                    color: "#4c4c4c"
                    ListView {
                        id: lv1
                        layer.enabled: true

                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: lv1.width
                                height: lv1.height
                                radius: 10
                            }
                        }
                        anchors.centerIn: parent
                        width: parent.width - 2
                        height: parent.height - 2
                        model: lv.model.values[lv.currentIndex] != undefined ? [
                            {
                                name: `Open ${lv.model.values[lv.currentIndex]?.name}`,
                                icon: "",
                                command: lv.model.values[lv.currentIndex]?.command
                            },
                            ...(lv.model.values[lv.currentIndex]?.actions ?? [])] : []
                        delegate: NButton {
                            required property var modelData
                            required property var index
                            width: lv1.width
                            content: modelData.name
                            elide: Text.ElideRight
                            onClicked: root.run(modelData)
                            background: Rectangle {
                                topRightRadius: index == 0 ? 10 : 0
                                topLeftRadius: index == 0 ? 10 : 0
                                bottomRightRadius: index == lv.count - 1 ? 10 : 0
                                bottomLeftRadius: index == lv.count - 1 ? 10 : 0
                                color: parent.ListView.isCurrentItem ? /*"#5c77aa"*/ Globals.settings.accent : (parent.hovered ? Globals.settings.button_bg_hover : Globals.settings.button_bg)
                            }
                            contentItem: Row {
                                spacing: 5
                                IconImage {
                                    source: Quickshell.iconPath(modelData.icon != "" ? modelData.icon : lv.model.values[lv.currentIndex]?.icon, true)
                                    implicitSize: 25
                                }
                                NText {
                                    text: modelData.name
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    width: parent.width - 30
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
