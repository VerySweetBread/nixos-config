import { Variable, bind } from "astal"
import Hyprland from "gi://AstalHyprland"

export default function Layout() {
    const hl = Hyprland.get_default();
    let layout = Variable("en");
    hl.connect("keyboard-layout", (_, __, l) => { layout.set(`${l}`.slice(0, 2).toLowerCase()) })

    return <box className={bind(layout).as((l) => `Layout ${l}`)}>
        <label label={bind(layout)}/>
    </box>
}
