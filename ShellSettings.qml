import Quickshell
import Quickshell.Io
import QtQuick
import QtCore

QtObject {
	id: root

	property string red: "#ff7777"
	property string blue: "#66bbdd"
	property string white: "#ffffff"

	property string accent: "#55aa77"
	property string accent1: "#55aa77"
	//property string alternate: "#ffffff"
	//property string accent: "#5232b7"
	
	property string grey0: "#0c0c0c"
	property string grey1: "#1c1c1c"
	property string grey2: "#252525"
	property string grey3: "#353535"
	property string grey4: "#454545"
	property string grey5: "#505050"
	property string grey6: "#656565"

    property string bgcol: grey1
    property string border: grey2

	property string button_bg: grey4
	property string button_bg_down: grey1
	property string button_bg_hover: grey6
	property double button_sidepad: 2.5

	property string text_fg: white
	property string text_font: "JetBrainsMono Nerd Font"
	property int text_size: 14

	property string input_bg: grey1
	property int input_text_size: 16
	property int input_radius: 10

	property string primaryScreen: "DP-1"
	
	property int brightnessTimeout: 10
	property int lockTimeout: 930
	property int screenOffTimeout: 900
	property int suspendTimeout: 1800

	property list<string> _pinnedApps: []

	property string _lastMode: "school"
	property string mode: "school"

	function getPrimaryScreen() {
		return Quickshell.screens.find(x => x.name == root.primaryScreen) || Quickshell.screens[Quickshell.screens.length - 1];
	}

    /*
	    */
}
