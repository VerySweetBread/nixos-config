import { bind } from "astal"
import Network from "gi://AstalNetwork"
import { execAsync } from "astal/process"

export default function Wifi() {
    const network = Network.get_default()
    const wifi = bind(network, "wifi")

    return <box visible={wifi.as(Boolean)}>
        {wifi.as(wifi => wifi && (
            <button
                className="Wifi"
                onClicked={() => {execAsync("kitty nmtui")}}>
                <box>
                    <icon
                        tooltipText={bind(wifi, "ssid").as(String)}
                        icon={bind(wifi, "iconName")}
                    />
                    <label
                        label={bind(wifi, "ssid").as(String)}
                    />
                </box>
            </button>
        ))}
    </box>
}
