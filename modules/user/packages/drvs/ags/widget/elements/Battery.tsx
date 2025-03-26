import { bind } from "astal";
import Battery from "gi://AstalBattery";
import accent from "../../accent.css";

export default function BatteryLevel() {
    const bat = Battery.get_default();
    const percent = bind(bat, "percentage").as(p => Math.floor(p * 100));

    return (
        <box 
            className="Battery" 
            visible={bind(bat, "isPresent")}
            css={percent.as(p => `
                background-image: linear-gradient(
                    to right,
                    ${accent} 0%,
                    ${accent} ${p}%,
                    transparent ${p}%,
                    transparent 100%
                );
                background-size: 100% 3px;
                background-repeat: no-repeat;
                background-position: bottom;
            `)}
        >
            <icon icon={bind(bat, "batteryIconName")} />
            <label label={percent.as(p => `${p}%`)} />
        </box>
    );
}
