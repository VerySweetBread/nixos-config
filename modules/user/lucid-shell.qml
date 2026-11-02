import "./luciddocks"
import "./lucidedit"
import "./lucidosd"
import "./lucidprefs"
import "./lucidwidgets"
import QtQuick
import Quickshell
import qs

ShellRoot {
    LucidBar {
        id: barRoot
        dock: dockRoot
        toastMod: toastMod
    }

    Dock {
        id: dockRoot
    }

    Toast {
        id: toastMod
    }

    ToastEvents {
        toast: toastMod
    }

    Binding {
        target: toastMod
        property: "screen"
        value: Monitors.shellPlacement
        when: Monitors.shellPlacement !== null
    }

    WidgetLayer {
    }

    WidgetIpc {
    }

    EditLayer {
    }

    SettingsHost {
    }

    Binding {
        target: Monitors
        property: "barWindows"
        value: barRoot.instances
    }
}
