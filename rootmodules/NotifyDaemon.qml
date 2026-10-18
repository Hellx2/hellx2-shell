import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.common
import qs

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
    	screen: Globals.settings.getPrimaryScreen()
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
                    height: mainItem.height + (col2.visible ? col2.height : 0)
                    width: parent.width
                    Rectangle {
                        color: "#1c1c1c"
                        border {
                            width: 1
                            color: "#3c3c3c"
                        }
                        radius: 10
                        width: parent.width
                        height: parent.height

                        Item {
                            anchors.fill: parent
                            Item {
                                width: parent.width
                                id: mainItem
                                height: Math.max(icon.height, text1.height + text2.height + text3.height + 20)
                                Rectangle {
                                	id: icon
                                	color: "transparent"
                                	anchors.margins: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: 5
                                    width: 100
                                    height: 100
                                    Image {
                                    	id: img
	                                    source: modelData.image
	                                    width: parent.width - 20
	                                    height: parent.height - 20
	                                    anchors.centerIn: parent
	                                    mipmap: true
	                                    layer.enabled: true
	                                    layer.effect: OpacityMask {
		                                	maskSource: Rectangle {
		                                		width: img.width
		                                		height: img.height
		                                		radius: 10
		                                	}
		                                }
	                                }
                                }
                                Column {
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    anchors.topMargin: 10
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
                                        width: parent.width
                                        elide: Text.ElideRight
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
                            Column {
                            	id: col2
                            	leftPadding: 10
                            	rightPadding: 10
                            	spacing: 5
                            	anchors.top: mainItem.bottom
                            	visible: modelData.actions.length > 0
                            	width: parent.width - 20
                            	height: mainRepeater.count * 35 - 5

                            	function getRows(model) {
                            		let rows = [[]];
                            		let index = 0;
                            		for (let i of model) {
                            			let temp = 0;
                            			if (rows[index].length == 0) {
                            				rows[index].push(i);
                            				continue;
                            			}
                            			// This ratio was calculated for JetBrains Mono and only that font, others will need to be implemented somehow
                            			for (let j of [...rows[index], i]) temp += j.text.length * Styles.text_size / 1.6 + 5 + 2 * Styles.button_sidepad;
                            			if (temp - 5 > col2.width) index++;
                            			if (index == rows.length) rows.push([]);
                            			rows[index].push(i);
                            		}
                            		return rows;
                            	}

                            	Repeater {
                            		id: mainRepeater
                            		model: col2.getRows(modelData.actions)
                            		Row {
                            			spacing: 5
                            			anchors.horizontalCenter: parent.horizontalCenter
                            			required property var modelData
                            			Repeater {
                            				model: modelData
                            				NButton {
                            					elide: Text.ElideRight
                            					width: Math.min(implicitWidth, col2.width - 20)
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
                            /*Grid {
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
                            }*/
                        }
                    }
                }
            }
        }
    }
}
