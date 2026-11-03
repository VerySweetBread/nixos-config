import "./luciddocks"
import "./lucidedit"
import "./lucidosd"
import "./lucidprefs"
import "./lucidshot"
import "./lucidwidgets"
import QtQuick
import Quickshell
import qs

ShellRoot {
    id: root

    Component.onCompleted: {
        void Clip.probed;
        void Capture.state;
    }

    function announceShot(entry) {
        if (Prefs.shotPreview === "preview") {
            shotCards.show(entry);
            return;
        }
        if (Prefs.shotPreview !== "notify")
            return;
        const where = String(entry.file).replace(Quickshell.env("HOME"), "~");
        if (entry.kind === "video")
            Quickshell.execDetached(["notify-send", "-a", "LucidShot", "-i", "media-record", "Recording saved", where]);
        else
            Quickshell.execDetached(["sh", "-c", "a=$(notify-send -a LucidShot -i \"$1\" -A 'edit=Mark up' -A 'open=Open' --wait \"$2\" \"$3\"); case \"$a\" in edit) qs ipc call snap edit \"$1\" ;; open) xdg-open \"$1\" ;; esac; true", "sh", entry.file, entry.temp ? "Screenshot copied" : "Screenshot saved", entry.temp ? "It is on the clipboard only" : where]);
    }

    ShotEngine {
        id: shotEngine
        cards: shotCards
        onReady: (entry) => {
            if (entry.owner === "overlay") {
                shotCards.update(entry);
                return;
            }
            if (entry.owner === "pin")
                return;
            root.announceShot(entry);
        }
        onFailed: (id, why) => toastMod.popup("warning", why, true)
        onTextRead: (r) => {
            if (!shotEngine.claim(r.id))
                return;
            if (r.status === "ok") {
                if (Prefs.shotPreview === "preview")
                    shotCards.show({ "id": r.id, "kind": "text", "text": r.text, "codes": r.codes, "screen": Monitors.focusedScreen ? Monitors.focusedScreen.name : "" });
                else
                    toastMod.popup("copy", "Text copied", false);
            } else if (r.status === "notool") {
                toastMod.popup("alert", "Install tesseract to copy text", true);
            } else {
                toastMod.popup("alert", "No text found", true);
            }
        }
    }

    ShotOverlay {
        id: shotOverlay
        engine: shotEngine
        cards: shotCards
        pins: shotPins
        onNotify: (icon, text, warn) => toastMod.popup(icon, text, warn)
        onSwatch: (hex, text) => toastMod.popupSwatch(hex, text)
        onFreezeFailed: (why) => toastMod.popup("alert", "Couldn't capture the screen", true)
    }

    ShotCards {
        id: shotCards
        engine: shotEngine
        pins: shotPins
        overlay: shotOverlay
    }

    PinBoard {
        id: shotPins
        engine: shotEngine
    }

    RecordHud {}

    Connections {
        target: Capture
        function onSaved(file, seconds) {
            root.announceShot({ "id": "rec-" + Date.now(), "kind": "video", "file": file, "duration": seconds, "screen": Capture.output });
        }
        function onFailed(why) {
            toastMod.popup("warning", why, true);
        }
    }

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

    Osd {
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
