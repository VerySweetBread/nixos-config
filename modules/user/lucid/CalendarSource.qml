import QtQuick
import Quickshell
import Quickshell.Io
import qs
pragma Singleton

// Read-only events already synchronized by Thunderbird. This deliberately does
// not connect to DAV or store credentials; Thunderbird remains the DAV client.
Singleton {
    id: source

    property var events: []
    property int tick: 0
    property string error: ""
    property real updatedAt: 0

    function refresh() {
        if (reader.running)
            return;
        reader.command = ["python3", Quickshell.env("HOME") + "/.config/quickshell/thunderbird-calendar.py"];
        reader.running = true;
    }

    function forDay(year, month, day) {
        source.tick;
        return source.events.filter((event) => {
            const date = new Date(event.startMs);
            return date.getFullYear() === year && date.getMonth() === month && date.getDate() === day;
        });
    }

    function upcoming(limit) {
        source.tick;
        const now = Loc.nowMs();
        return source.events.filter((event) => event.startMs >= now).slice(0, limit || source.events.length).map((event) => ({
            "item": source.asAgendaItem(event),
            "at": new Date(event.startMs)
        }));
    }

    function hasOn(year, month, day) {
        return source.forDay(year, month, day).length > 0;
    }

    function asAgendaItem(event) {
        const date = new Date(event.startMs);
        return {
            "id": "thunderbird:" + event.id,
            "name": event.name,
            "calendar": event.calendar,
            "source": "thunderbird",
            "startMs": event.startMs,
            "endMs": event.endMs,
            "hour": date.getHours(),
            "minute": date.getMinutes(),
            "repeat": ""
        };
    }

    Process {
        id: reader

        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() === "")
                    return;
                try {
                    const result = JSON.parse(this.text);
                    if (!result.error) {
                        source.events = result.events || [];
                        source.error = "";
                        source.updatedAt = Date.now();
                        source.tick++;
                    } else {
                        source.error = result.error;
                    }
                } catch (e) {
                    source.error = "Could not read Thunderbird calendar cache";
                }
            }
        }

        onExited: (code) => {
            if (code !== 0 && source.error === "")
                source.error = "Could not read Thunderbird calendar cache";
        }
    }

    Timer {
        interval: 300000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: source.refresh()
    }
}
