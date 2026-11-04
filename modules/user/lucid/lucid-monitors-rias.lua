-- Initial Rias display layout; Home Manager seeds this only while the
-- user-owned Lucid monitor list is empty.
return {
    monitors = {
        { output = "DP-3", mode = "3440x1440@165", position = "auto-right", scale = "1" },
        { output = "HDMI-A-1", disabled = true },
    },
    workspaces = {},
}
