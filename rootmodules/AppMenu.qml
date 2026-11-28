pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtCore
import qs.core

Panel {
    id: root
    panelName: "appMenu"
    implicitWidth: 500
    implicitHeight: 500
    anchorLeft: true
    anchorBottom: true
    ignoreExclusion: false

    onVisibleChanged: mainInput.text = ""

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

    function run(entry) {
        let hist = JSON.parse(history);
        hist[entry.id] = (hist[entry.id] ?? 0) + 1;
        history = JSON.stringify(hist);

        Quickshell.execDetached(entry.command);
        PanelManager.clearActivePanel();
        mainInput.text = "";
    }

    Column {
        anchors.fill: parent
        anchors.margins: 1

        Row {
            id: topRow
            width: parent.width - 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            spacing: 5
            IconImage {
                source: Quickshell.iconPath("edit-find", true)
                implicitSize: 24
                anchors.verticalCenter: parent.verticalCenter
            }
            NInput {
                id: mainInput
                bgcolor: "transparent"
                focus: true
                font.bold: false
                width: parent.width - 30
                fontSize: 18
                height: 50
                Keys.onDownPressed: lv.incrementCurrentIndex()
                Keys.onUpPressed: lv.decrementCurrentIndex()
                Keys.onEscapePressed: {
                    PanelManager.clearActivePanel();
                    text = "";
                }
                font.family: Globals.theme.text_font

                onAccepted: root.run(lv.model.values[lv.currentIndex]?.data)
            }
        }
        Row {
            height: parent.height - 55
            width: parent.width - 10
            anchors.bottomMargin: 5
            spacing: 7.5
            anchors.horizontalCenter: parent.horizontalCenter
            ListBox {
                id: lv
                width: parent.width * 5 / 8 - 5
                height: parent.height
                model: ScriptModel {
                    values: root.model.sort((a, b) => {
                        let hist = JSON.parse(root.history);
                        let A = a.name.toUpperCase();
                        let B = b.name.toUpperCase();
                        return ((a, b) => {
                                let rv = (!!hist[a.id] && (!hist[b.id] || (hist[a.id] > hist[b.id]))) ? -1 : ((!hist[a.id] || hist[b.id] > hist[a.id]) ? 1 : 0);
                                return rv;
                            })(a, b) || (A < B ? -1 : (A > B ? 1 : 0));
                    }).filter(x => [x.id, x.name].filter(a => a.toLowerCase().includes(mainInput.text.toLowerCase())).length > 0).map(x => ({
                                "icon": x.icon,
                                "text": x.name,
                                "subtext": x.genericName,
                                "actions": x.actions,
                                "data": {
                                    "command": x.command,
                                    "id": x.id
                                }
                            }))
                    onValuesChanged: lv.currentIndex = 0
                }
                onBtnClick: data => root.run(JSON.parse(data))
            }
            Rectangle {
                height: parent.height
                width: parent.width * 3 / 8 - 5
                radius: 10
                border {
                    width: 1
                    color: (Globals.theme.dark ? Qt.darker : Qt.lighter)(color)
                }
                color: Qt.lighter(Globals.theme.bgcol)
                ListBox {
                    id: lv1
                    defaultIcon: lv.model.values[lv.currentIndex]?.icon
                    anchors.centerIn: parent
                    width: parent.width - 2
                    height: parent.height - 2
                    model: lv.model.values[lv.currentIndex] != undefined ? [
                        {
                            "text": `Open`,
                            "icon": "",
                            "data": lv.model.values[lv.currentIndex]?.data
                        },
                        ...(lv.model.values[lv.currentIndex]?.actions?.map(x => ({
                                        "text": x.name,
                                        "icon": x.icon,
                                        "data": {
                                            "command": x.command,
                                            "id": lv.model.values[lv.currentIndex]?.data?.id
                                        }
                                    })) ?? [])] : []
                    onBtnClick: data => root.run({
                            id: lv.model.values[lv.currentIndex]?.id,
                            command: JSON.parse(data)
                        })
                }
            }
        }
    }
}
