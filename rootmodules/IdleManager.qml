pragma Singleton
import Quickshell
import Quickshell.Wayland
import qs.common
import qs

Singleton {
    id: root
    property bool running: true

    component Monitor : IdleMonitor {
        required property list<string> timeoutCmd
        property list<string> resumeCmd: []
        enabled: root.running
        onIsIdleChanged: {
            if(isIdle) Quickshell.execDetached(timeoutCmd)
            else if (resumeCmd != []) Quickshell.execDetached(resumeCmd)
        }
    }

    Monitor {
        timeout: Globals.settings.brightnessTimeout
        timeoutCmd: ['brightnessctl', '-s', 'set', '10']
        resumeCmd: ['brightnessctl', '-r']
    }

    Monitor {
        timeout: Globals.settings.brightnessTimeout
        timeoutCmd: ['brightnessctl', '-sd', 'rgb:kbd_backlight', 'set', '0']
        resumeCmd: ['brightnessctl', '-rd', 'rgb:kbd_backlight']
    }

    Monitor {
        timeout: Globals.settings.lockTimeout
        timeoutCmd: ['loginctl', 'lock-session']
    }

    Monitor {
        timeout: Globals.settings.screenOffTimeout
        timeoutCmd: ['niri', 'msg', 'action', 'power-off-monitors']
        resumeCmd: ['sh', '-c', 'niri msg action power-on-monitors && brightnessctl -r']
    }

    Monitor {
        timeout: Globals.settings.suspendTimeout
        timeoutCmd: ['systemctl', 'suspend']
    }
}
