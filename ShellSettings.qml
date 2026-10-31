import Quickshell
import Quickshell.Io
import QtQuick
import QtCore

QtObject {
	id: root

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
