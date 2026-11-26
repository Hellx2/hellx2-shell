pragma Singleton

import Quickshell
import QtCore

Singleton {
    id: root
    ShellSettings {
        id: shellSettings
    }
    Theme {
        id: shellTheme
    }

    property ShellSettings settings: shellSettings
    property Theme theme: shellTheme
    property var mainSettings: ({})

    property var settingsMan: settingsInst

    Settings {
        id: settingsInst
        property string mainSettings: JSON.stringify(root.mainSettings)
        property string theme: JSON.stringify(root.theme)
    }
}
