import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property var entries: []
    property bool loading: false
    property string error: ""
    property string targetAddress: ""
    property string pendingPassword: ""
    property var passwordProcess: null

    signal passwordReady(string password, string targetAddress)

    function refresh() {
        if (listReader.running)
            return;

        root.loading = true;
        root.error = "";
        listReader.command = ["rbw", "list", "--fields", "id,name,user,folder"];
        listReader.running = true;
    }

    function getPassword(id, target) {
        if (root.passwordProcess)
            return;

        root.targetAddress = target || "";
        root.error = "";
        root.passwordProcess = passwordProcessComponent.createObject(root, { entryId: id });
        if (!root.passwordProcess) {
            root.error = "Could not start rbw.";
            return;
        }
        root.passwordProcess.running = true;
    }

    function typePassword(password, target) {
        root.pendingPassword = password;
        root.targetAddress = target || "";
        typeDelay.restart();
    }

    Process {
        id: listReader

        command: []
        stdout: StdioCollector {
            id: listOutput
        }

        onExited: (code) => {
            root.loading = false;
            if (code !== 0) {
                root.error = "Could not read the vault. Unlock it with rbw, then retry.";
                root.entries = [];
                return;
            }

            root.entries = listOutput.text.split(/\r?\n/).filter((line) => line !== "").map((line) => {
                const fields = line.split("\t");
                return {
                    id: fields[0] || "",
                    name: fields[1] || "Untitled",
                    user: fields[2] || "",
                    folder: fields[3] || ""
                };
            }).filter((entry) => entry.id !== "");
            root.error = "";
        }
    }

    Component {
        id: passwordProcessComponent

        Process {
            id: passwordJob

            property string entryId: ""
            command: ["rbw", "get", entryId]
            stdout: StdioCollector {
                id: passwordOutput
            }

            onExited: (code) => {
                if (root.passwordProcess === passwordJob)
                    root.passwordProcess = null;
                if (code !== 0) {
                    root.error = "Could not read that password.";
                } else {
                    root.passwordReady(passwordOutput.text.replace(/\r?\n$/, ""), root.targetAddress);
                }
                passwordJob.destroy();
            }
        }
    }

    Process {
        id: typer

        command: ["wtype", "-"]
        stdinEnabled: true
        onStarted: {
            write(root.pendingPassword);
            stdinEnabled = false;
            root.pendingPassword = "";
            root.targetAddress = "";
        }
    }

    Timer {
        id: typeDelay

        interval: 260
        onTriggered: {
            if (root.targetAddress !== "")
                Hyprland.dispatch("focuswindow address:" + root.targetAddress);

            typer.running = false;
            typer.stdinEnabled = true;
            typer.running = true;
        }
    }
}
