import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit
import qs.common

PanelWindow {
	// Will be Exclusive when keybinds added
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
	id: root
	implicitWidth: 500
	implicitHeight: 200
	color: "transparent"
	visible: agent.flow && agent.flow?.isResponseRequired && !agent.flow?.isCompleted && !agent.flow?.isCancelled
	Rectangle {
		anchors.fill: parent
		color: "#1c1c1c"
		radius: 12
		border {
			width: 1
			color: "#3c3c3c"
		}
	}

	PolkitAgent {
		id: agent
		onFlowChanged: {
			//root.visible = true
			console.warn("Testing")
			if (flow) {
				message.text = flow.message
				console.warn(JSON.stringify(agent.flow.identities))
			}
			//flow.cancelAuthenticationRequest()
		}
	}
	Text {
		anchors.horizontalCenter: parent.horizontalCenter
		horizontalAlignment: Text.AlignHCenter
		width: parent.width - 20
		anchors.top: parent.top
		anchors.topMargin: 10
		id: message
		color: "#ffffff"
		wrapMode: Text.WordWrap
	}
	QCombo {
		id: userPicker
		anchors.top: message.bottom
		anchors.topMargin: 10
		haveNA: false
		label: "User: "
		model: agent.flow && agent.flow.identities.map(x => x.string)
	}
	NInput {
		anchors.top: userPicker.bottom
		anchors.topMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width - 20
		bgcolor: "#0c0c0c"
		//height: 20
	}
}
