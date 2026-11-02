import "./luciddocks"
import "./lucidedit"
import "./lucidprefs"
import "./lucidwidgets"
import QtQuick
import Quickshell
import qs

ShellRoot {
    LucidBar {
        id: barRoot
        dock: dockRoot
    }

    Dock {
        id: dockRoot
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
