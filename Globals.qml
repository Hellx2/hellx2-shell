pragma Singleton

import Quickshell
import Quickshell.Io
import QtCore
import qs.common

Singleton {
    id: root
    ShellSettings {
        id: shellSettings
    }
    property ShellSettings settings: shellSettings
}
