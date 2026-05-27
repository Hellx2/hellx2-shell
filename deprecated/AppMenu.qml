pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.common

Scope {
    id: root
    property bool showAppMenu: false
    property bool focusable: true
    IpcHandler {
        function toggle() {
            if (root.showAppMenu)
                root.close();
            else
                root.showAppMenu = true;
        }
        function show() {
            root.showAppMenu = true;
        }
        function hide() {
            // Prevent unnecessary calls
            if (root.showAppMenu)
                root.close();
        }
        target: "appMenu"
    }

    function close() {
        focusable = false;
        root.showAppMenu = false;
    }

    LazyLoader {
        active: root.showAppMenu

        NWindow {
            id: appMenu
            Component.onCompleted: {
                root.focusable = true;
            }
            anchors {
                left: true
                bottom: true
            }
            margins.left: 10
            margins.bottom: 10
            color: "transparent"
            iwidth: 500
            iheight: 600
            focusable: root.focusable

            property string query: ""

            function launchSelected() {
                if (listView.currentItem && listView.currentItem.modelData) {
                    listView.currentItem.modelData.execute();
                    root.close();
                }
            }

            Timer {
                id: focusTimer
                interval: 10
                running: false
                repeat: false
                onTriggered: page1.header.data[0].data[1].forceActiveFocus()
            }

            onVisibleChanged: function () {
                if (visible) {
                    focusTimer.running = true;
                }
            }

            Item {
                anchors.fill: parent
                Rectangle {
                    anchors.fill: parent
                    color: "#252525"
                    radius: 10
                    border {
                        color: "#252525"
                        width: 2
                    }
                }

                // Filtered model: only items matching the query
                ScriptModel {
                    id: filtered
                    values: {
                        const allEntries = [...DesktopEntries.applications.values];
                        allEntries.sort((a, b) => a.name > b.name ? 1 : -1);
                        const q = appMenu.query.trim();

                        if (q === "") {
                            return allEntries;
                        } else {
                            return allEntries.filter(d => d.name && d.name.toLowerCase().includes(q));
                        }
                    }
                }
                Page {
                    id: page1
                    background: Item {}
                    anchors.fill: parent
                    header: Rectangle {
                        width: parent.width
                        height: 50
                        color: "#151515"
                        topLeftRadius: 10
                        topRightRadius: 10

                        z: 2
                        RowLayout {
                            NText {
                                Layout.leftMargin: 10
                                height: 50
                                width: 30
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: " > "
                                fontSize: 20
                            }
                            NInput {
                                bgcolor: "transparent"
                                width: parent.width - 50
                                height: 50

                                Layout.fillWidth: true
                                fontSize: 18
                                pltext: "Run…"

                                onTextChanged: appMenu.query = text
                                // Quit
                                Keys.onEscapePressed: {
                                    root.close();
                                    text = "";
                                }
                                Keys.onPressed: event => {
                                    const ctrl = event.modifiers & Qt.ControlModifier;
                                    if (event.key == Qt.Key_Up || event.key == Qt.Key_P && ctrl) {
                                        event.accepted = true;
                                        if (listView.currentIndex > 0)
                                            listView.currentIndex--;
                                    } else if (event.key == Qt.Key_Down || event.key == Qt.Key_N && ctrl) {
                                        event.accepted = true;
                                        if (listView.currentIndex < listView.count - 1)
                                            listView.currentIndex++;
                                    } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                                        event.accepted = true;
                                        appMenu.launchSelected();
                                    } else if (event.key == Qt.Key_C && ctrl) {
                                        event.accepted = true;
                                        root.close();
                                    }
                                }
                            }
                        }
                    }

                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        cacheBuffer: 50000
                        currentIndex: filtered.values.length > 0 ? 0 : -1
                        clip: true
                        keyNavigationWraps: true
                        preferredHighlightBegin: 0
                        preferredHighlightEnd: height
                        highlightRangeMode: ListView.ApplyRange
                        highlightMoveDuration: 80
                        highlight: Rectangle {
                            radius: 4
                            opacity: 0.45
                            color: "#3399ff"
                        }

                        anchors.fill: parent
                        model: filtered.values
                        spacing: 6

                        delegate: Item {
                            height: 45
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            MouseArea {
                                anchors.fill: parent
                                onClicked: list.currentIndex = entry.index
                                onDoubleClicked: launcher.launchSelected()
                            }
                            Row {
                                id: row1
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10
                                IconImage {
                                    source: Quickshell.iconPath(modelData.icon, true)
                                    width: 30
                                    height: 30
                                }
                                NText {
                                    color: "#cccccc"
                                    text: modelData.name
                                    fontSize: 18
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        ScrollBar.vertical: ScrollBar {}
                    }
                }
            }
        }
    }
}
