import { bind } from "astal"
import Wp from "gi://AstalWp"

export default function Audio() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    return <box className="AudioSlider">
        <icon icon={bind(speaker, "volumeIcon")} />
        <label label={bind(speaker, "volume").as(v => `${Math.floor(v*100)}%`)} />
    </box>
}
