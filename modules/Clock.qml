import Quickshell
import qs.common
import QtQuick

NButton {
    id: btn1
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    property bool showDate: false
    onClicked: showDate = !showDate
    contentItem: NText {
        id: txt1
        horizontalAlignment: Text.AlignHCenter
        anchors.top: parent.top
        anchors.topMargin: 6.25
        text: Qt.formatDateTime(clock.date, btn1.showDate ? "dd/MM/yy" : "hh:mm")
    }
    width: txt1.implicitWidth + 15
    height: 30
}
