import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit
import qs.common

PanelWindow {
    id: root
    // Will be Exclusive when keybinds added
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    implicitWidth: 500
    implicitHeight: (resultText.visible ? 125 : 100) + message.height
    color: "transparent"
    visible: agent.flow && !agent.flow?.isCompleted && !agent.flow?.isCancelled
    Rectangle {
        anchors.fill: parent
        color: "#1c1c1c"
        radius: 12
        border {
            width: 1
            color: "#3c3c3c"
        }
    }

    property bool isAuthenticating: false

    PolkitAgent {
        id: agent
        onFlowChanged: {
            //root.visible = true
            console.warn("Testing");
            if (flow) {
                message.text = flow.message;
                console.warn(JSON.stringify(agent.flow.identities));
            } else {
                passwordInput.text = "";
            }
            //flow.cancelAuthenticationRequest()
        }
    }

    Text {
        id: message
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - 20
        anchors.top: parent.top
        anchors.topMargin: 10
        color: "#ffffff"
        wrapMode: Text.WordWrap
    }
    QCombo {
        id: userPicker
        anchors.top: message.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        haveNA: false
        label: "User: "
        model: agent.flow && agent.flow.identities.map(x => x.string)
    }
    Connections {
        target: agent.flow
        function onIsResponseRequiredChanged() {
            console.warn("HI");
            if (root.isAuthenticating)
                root.isAuthenticating = false;
            if (agent.flow.isResponseRequired && agent.flow.failed) {
                passwordInput.text = "";
            }
        }
    }
    // TODO: Make this hide the password
    NInput {
        id: passwordInput
        focus: true
        anchors.top: userPicker.bottom
        anchors.topMargin: 10
        leftPadding: 10
        rightPadding: 10
        topPadding: 2.5
        bottomPadding: 2.5
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        bgcolor: "#4c4c4c"
        readOnly: agent.flow && !agent.flow.isResponseRequired
        horizontalAlignment: TextInput.AlignHCenter
        onAccepted: {
            agent.flow.submit(text);
            isAuthenticating = true;
        }
        echoMode: agent.flow && agent.flow.responseVisible ? TextInput.Normal : TextInput.Password
        font.letterSpacing: 2.5
    }
    NText {
        id: resultText
        anchors.top: passwordInput.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: isAuthenticating ? "..." : "Invalid password!"
        color: isAuthenticating ? Styles.blue : Styles.red
        visible: isAuthenticating || (agent.flow && agent.flow.failed && !agent.flow.isCompleted)
    }
}
