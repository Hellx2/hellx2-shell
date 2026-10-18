import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.common

FloatingWindow {
    implicitWidth: 800
    implicitHeight: 600

    visible: false

    color: Globals.settings.bgcol
    title: "Hellx2 Shell - Settings"

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5
        model: Object.getOwnPropertyNames(Globals.settings).filter(x => {
            return !x.startsWith("_") && !x.endsWith("Changed")
            && x != "objectName" && typeof Globals.settings[x] !== "function"
        })
        delegate: Row {
            NText {
                text: modelData.replace(/(.)_(.)|([a-z])([A-Z0-9])/g, (_, p1, p2, p3, p4) => {
                    return `${p1 || p3} ${p2?.toUpperCase() || p4 }`
                }).replace(/^(.)/, (x) => {
                    return x.toUpperCase()
                }) + ": "
                width: 200
            }
            NInput {
                id: input1
                width: 300
                bgcolor: Globals.settings.grey3
                text: Globals.settings[modelData]
                validator: RegularExpressionValidator {
                    regularExpression: {
                        if (typeof Globals.settings[modelData] == "number")
                        return /\d{1,4}(\.\d?)/
                        else if ((/#[0-9a-f]{3,6}/i).test(Globals.settings[modelData])) {
                            return /#[0-9a-f]{3,6}/i
                        }
                        else return /.*/
                    }
                }
                leftPadding: 5
                rightPadding: 5
                onAccepted: {
                    Globals.settings[modelData] = this.text
                }
            }
        }
    }
}
