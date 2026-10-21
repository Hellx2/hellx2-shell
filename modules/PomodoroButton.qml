import QtQuick
import qs.common
import qs.rootmodules
import qs

MouseArea {
	id: btn1
	property bool onTopBar: false
    hoverEnabled: true
    enabled: Pomodoro.buttonEnabled
	clip: true
	height: 30
	width: 30 + (containsMouse ? txt2.width : 0)
	onClicked: Pomodoro.showPomodoro = !Pomodoro.showPomodoro
	Component.onCompleted: Pomodoro.onTopBar = onTopBar
	Rectangle {
		anchors.fill: parent
		color: Globals.settings.button_bg
		radius: height / 2
	}

    Row {
    	anchors.verticalCenter: parent.verticalCenter
    	anchors.left: parent.left
    	anchors.leftMargin: 5
    	width: parent.width - 10
    	clip: true
    	NText {
    		text: "🕑"
    		fontSize: 16
    		anchors.verticalCenter: parent.verticalCenter
    	}
    	NText {
    		id: txt2
    		color: Pomodoro.col
    		visible: btn1.containsMouse
            text: " " + String((Pomodoro.countdown - Pomodoro.countdown % 3600) / 3600).padStart(2, 0) + ":"
            + String((Pomodoro.countdown % 3600 - Pomodoro.countdown % 60) / 60).padStart(2, 0) + ":"
            + String(Pomodoro.countdown % 60).padStart(2, 0)
    	}
    }

    Behavior on width {
    	SmoothedAnimation {
    		duration: 200
    	}
    }
}
