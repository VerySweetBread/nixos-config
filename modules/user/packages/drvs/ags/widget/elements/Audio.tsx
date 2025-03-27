import { bind } from "astal"
import { execAsync } from "astal/process"
import Wp from "gi://AstalWp"

export default function Audio() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    return <button
        className="AudioSlider"
        onClicked={() => { execAsync("ghostty --title=pulsemixer -e pulsemixer") }}>
        <box>
            <icon icon={bind(speaker, "volumeIcon")} />
            <label label={bind(speaker, "volume").as(v => `${Math.floor(v*100)}%`)} />
        </box>
    </button>
}
