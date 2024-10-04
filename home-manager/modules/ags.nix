{ inputs, pkgs, config, ... }: {
  # imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;

    # null or path, leave as null if you don't want hm to manage the config
    configDir = null;

    # additional packages to add to gjs's runtime
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

  xdg.configFile."ags/config.js".text = /*js*/ ''
const hyprland = await Service.import("hyprland")
const notifications = await Service.import("notifications")
const mpris = await Service.import("mpris")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const systemtray = await Service.import("systemtray")

const date = Variable("", {
    poll: [1000, 'date "+%H:%M:%S %b %e."'],
})

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

function Workspaces() {
    const activeId = hyprland.active.workspace.bind("id")
    const workspaces = hyprland.bind("workspaces")
        .as(ws => ws.map(({ id }) => Widget.Button({
            on_clicked: () => hyprland.messageAsync(`dispatch workspace ''${id}`),
            child: Widget.Label(`''${id}`),
            class_name: activeId.as(i => `''${i === id ? "focused" : ""}`),
        })))

    return Widget.Box({
        class_name: "workspaces",
        children: workspaces,
    })
}


function ClientTitle() {
    return Widget.Label({
        class_name: "client-title",
        label: hyprland.active.client.bind("title"),
    })
}


function Clock() {
    return Widget.Label({
        class_name: "clock",
        label: date.bind(),
    })
}


// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
function Notification() {
    const popups = notifications.bind("popups")
    return Widget.Box({
        class_name: "notification",
        visible: popups.as(p => p.length > 0),
        children: [
            Widget.Icon({
                icon: "preferences-system-notifications-symbolic",
            }),
            Widget.Label({
                label: popups.as(p => p[0]?.summary || ""),
            }),
        ],
    })
}


function Media() {
    const label = Utils.watch("default", mpris, "player-changed", () => {
        if (mpris.players[0]) {
            const { track_artists, track_title } = mpris.players[0]
            return `''${track_artists.join(", ")} - ''${track_title}`
        } else {
            return "Nothing is playing"
        }
    })

    print(Object.values(label))
    if (label != "default") {
        return Widget.Button({
            class_name: "media",
            on_primary_click: () => mpris.getPlayer("")?.playPause(),
            on_scroll_up: () => mpris.getPlayer("")?.next(),
            on_scroll_down: () => mpris.getPlayer("")?.previous(),
            child: Widget.Label({ label }),
        })
    }
}


function Volume() {
    const icons = {
        101: "overamplified",
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `audio-volume-''${icons[icon]}-symbolic`
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    })

    const slider = Widget.Slider({
        hexpand: true,
        draw_value: false,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0
        }),
    })

    return Widget.Box({
        class_name: "volume",
        css: "min-width: 180px",
        children: [icon, slider],
    })
}


function BatteryLabel() {
    const value = battery.bind("percent").as(p => p > 0 ? p / 100 : 0)
    const icon = battery.bind("percent").as(p =>
        `battery-level-''${Math.floor(p / 10) * 10}-symbolic`)

    return Widget.Box({
        class_name: "battery",
        visible: battery.bind("available"),
        children: [
            Widget.Icon({ icon }),
            Widget.LevelBar({
                widthRequest: 140,
                vpack: "center",
                value,
            }),
        ],
    })
}


function SysTray() {
    const items = systemtray.bind("items")
        .as(items => items.map(item => Widget.Button({
            child: Widget.Icon({ icon: item.bind("icon") }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })))

    return Widget.Box({
        children: items,
    })
}


// layout of the bar
function Left() {
    return Widget.Box({
        spacing: 8,
        children: [
            Workspaces(),
            ClientTitle(),
        ],
    })
}

function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            Media(),
            Notification(),
        ],
    })
}

function Right() {
    return Widget.Box({
        hpack: "end",
        spacing: 8,
        children: [
            Volume(),
            BatteryLabel(),
            Clock(),
            SysTray(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-''${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(),
            center_widget: Center(),
            end_widget: Right(),
        }),
    })
}

App.config({
    style: "./style.css",
    windows: [
        Bar(),

        // you can call it, for each monitor
        // Bar(0),
        // Bar(1)
    ],
})

export { }
'';

  xdg.configFile."ags/style.css".text = let
    colors = config.lib.stylix.colors;
    
    color = {
        base      = colors.base00;
        mantle    = colors.base01;
        surface0  = colors.base02;
        surface1  = colors.base03;
        surface2  = colors.base04;
        text      = colors.base05;
        rosewater = colors.base06;
        lavander  = colors.base07;
        red       = colors.base08;
        peach     = colors.base09;
        yellow    = colors.base0A;
        green     = colors.base0B;
        teal      = colors.base0C;
        blue      = colors.base0D;
        mauve     = colors.base0E;
        flamingo  = colors.base0F;
    };
in /*css*/ ''
* {
    border: none;
    box-shadow: none;
    text-shadow: none;
}

window.bar {
    background-color: transparent;
    color: #${color.text};
}

button {
    /* size: 20px; */
    background-color: transparent;
    border-radius: 10px;
}

button:active {
    background-color: /*#${color.surface0}*/ red;
}

label {
    font-weight: bold;
}

.workspaces {
    background-color: #${color.base};
    border-radius: 10px;
}

.workspaces button {
    color: #${color.surface2};
    background: transparent;
    padding: 5px;
}

.workspaces button:hover {
    color: #${color.text};
}

.workspaces button.focused {
    background-color: #${color.surface0};
    color: #${color.text};
}

.client-title {
    color: @theme_selected_bg_color;
}

.notification {
    color: yellow;
}

levelbar block,
highlight {
    min-height: 10px;
}
'';

  # home.packages = [ pkgs.ags ];
}
