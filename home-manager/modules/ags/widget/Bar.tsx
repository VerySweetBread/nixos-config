import { App } from "astal/gtk3"
import { Astal, Gtk, Gdk } from "astal/gtk3"

import Time         from "./elements/Time"
import Wifi         from "./elements/Wifi"
import Audio        from "./elements/Audio"
import Media        from "./elements/Media"
import SysTray      from "./elements/SysTray"
import Workspaces   from "./elements/Workspaces"
import BatteryLevel from "./elements/Battery"


export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <Workspaces />
            </box>
            <box>
                <Media />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <SysTray />
                <Wifi />
                <Audio />
                <BatteryLevel />
                <Time />
            </box>
        </centerbox>
    </window>
}
