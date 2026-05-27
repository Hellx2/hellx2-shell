import Quickshell
import qs.common
import QtQuick

Row {
	SystemClock { id: clock; precision: SystemClock.Minutes }
    NButton { content: Qt.formatDateTime(clock.date, "hh:mm") }
}
