-- Initial Rias display layout; Home Manager seeds this only while the
-- user-owned Lucid monitor list is empty.
return {
    monitors = {
        { output = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622", mode = "3440x1440@120.00", position = "1920x0", scale = "1" },
        { output = "desc:Samsung Electric Company SAMSUNG 0x01000E00", mode = "1920x1080@60.00", position = "0x0", scale = "1" },
    },
    workspaces = {
        { workspace = "2", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622", default = true },
        { workspace = "11", monitor = "desc:Samsung Electric Company SAMSUNG 0x01000E00", default = true },
    },
}
