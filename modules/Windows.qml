import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.common
import qs

Row {
	id: root
    property string screen: "eDP-1"
    spacing: 5
    ScriptModel {
        id: apps
        values: ToplevelManager.toplevels.values.filter(x => !Globals.settings._pinnedApps.includes(x.appId))
    }
    ScriptModel {
        id: pinnedApps
        values: ToplevelManager.toplevels.values.filter(x => Globals.settings._pinnedApps.includes(x.appId))
    }


    Repeater {
        model: ScriptModel {
            values: Globals.settings._pinnedApps
        }
        MouseArea {
            height: root.height - 2.5
            required property var modelData
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            //bgcolor: modelData
            id: btn
            width: 25 + indicator.width + 5 //+ (activeWin == -1 ? 0 : txt1.width + 5)
            //height: 25
            property var windows: pinnedApps.values.filter(x => x.appId == modelData)
            property int activeWin: windows.findIndex(x => x.activated)
            Rectangle {
                radius: height / 2
                anchors.fill: parent
                color: activeWin != -1 ? Globals.theme.grey6 : Globals.theme.grey4
            }
            onClicked: m => {
                if (m.button & Qt.LeftButton)
                if (windows.length > 0) windows[activeWin + 1 == windows.length ? 0 : activeWin + 1].activate()
                else Quickshell.execDetached(DesktopEntries.byId(modelData).command)
                else if (m.button & Qt.RightButton && windows.length > 0) windows[Math.max(activeWin, 0)].close();
                else if (m.button & Qt.MiddleButton) Globals.settings._pinnedApps.splice(Globals.settings._pinnedApps.indexOf(modelData), 1)
            }
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 2.5
                spacing: 2.5
                Image {
                    source: Quickshell.iconPath(DesktopEntries.byId(modelData)?.icon, true)
                    width: 20
                    height: 20
                    mipmap: true
                }
                /*NText {
                    id: txt1
                    leftPadding: 2.5
                    text: visible && windows[activeWin].title
                    visible: activeWin != -1
                    width: Math.min(implicitWidth, 200)
                    elide: Text.ElideRight
                }*/
                Rectangle {
                    id: indicator
                    //visible: btn.windows.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    color: activeWin == -1 ? '#00b0aa' : '#12b0ff'
                    border { color: Qt.lighter(indicator.color, 1.1); width: 1 }
                    radius: height / 2
                    //anchors.bottom: parent.bottom
                    //anchors.right: parent.right
                    height: 14
                    width: children[0].text.length > 1 ? 21 : 14
                    NText {
                        fontSize: 11
                        font.family: "Noto Sans"
                        font.bold: true
                        anchors.centerIn: parent
                        text: btn.windows.length > 9 ? "9+" : `${btn.windows.length}`
                    }
                }
            }
        }
    }

    Spacer { strokeColor: rep1.model.values.length > 0 ? Globals.theme.grey4 : "transparent"} //visible: rep1.model.values.length > 0 }

    Repeater {
        id: rep1
        model: ScriptModel {
            values: NiriService.windows.filter(w => NiriService.workspaces[w.workspace_id].is_active
            && NiriService.workspaces[w.workspace_id].output == root.screen)
            //&& !Globals.settings._pinnedApps.includes(w.app_id))
        }

        MouseArea {
            required property var modelData
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            width: 27.5
            height: 27.5
            Rectangle {
                radius: height / 2
                anchors.fill: parent
                color: modelData.is_focused ? Globals.theme.grey6 : Globals.theme.grey4
            }
            onClicked: m => {
                if (m.button & Qt.LeftButton) NiriService.focusWindow(modelData.id)
                else if (m.button & Qt.RightButton) NiriService.closeWindow(modelData.id);
                else if (m.button & Qt.MiddleButton) {
                    if (!Globals.settings._pinnedApps.includes(modelData.app_id))
                    Globals.settings._pinnedApps.push(modelData.app_id)
                }
            }

            Image {
                anchors.centerIn: parent
                source: Quickshell.iconPath(DesktopEntries.byId(modelData.app_id)?.icon, true)
                width: 20
                height: 20
                mipmap: true
            }
            /*NText {
                 rightPadding: 2.5
                 leftPadding: 2.5
                 text: modelData.title
                 visible: modelData.is_focused
                 width: Math.min(implicitWidth, 200)
                 elide: Text.ElideRight
             }*/
        }
    }
}
