import { Variable, bind } from "astal"
import { Gtk } from "astal/gtk3"
import Mpris from "gi://AstalMpris"

export default function Media() {
    const mpris = Mpris.get_default()
    // console.log(bind(mpris, "players").as(ps => ps[0] ? `${ps[0].title} ${ps[0].artist} ${ps[0].get_playback_status()}` : "-"));

    return <box>
        {bind(mpris, "players").as(ps => ps[0] ? (
            <button
                className={bind(ps[0], "playback-status").as(s => s == 0 ? "Media playing" : "Media")}
                onClicked={() => ps[0].play_pause()}>
                <box>
                    <box
                        className="Cover"
                        valign={Gtk.Align.CENTER}
                        css={bind(ps[0], "coverArt").as(cover =>
                            `background-image: url('${cover}');`
                        )}
                    />
                    <label
                        label={bind(ps[0], "title").as(() =>ps[0].title.length < 80 ?  ps[0].title : `${ps[0].title.slice(0, 77)}...`)}
                    />
                </box>
            </button>
        ) : ("") )}
    </box>
}
