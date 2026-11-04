-- Initial Rias display layout; Home Manager seeds this only while the
-- user-owned Lucid monitor list is empty.
return {
    monitors = {
        { output = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622", mode = "3440x1440@120.00", position = "1920x0", scale = "1" },
        { output = "desc:Samsung Electric Company SAMSUNG 0x01000E00", disabled = true },
    },
    workspaces = {
        { workspace = "1", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622", default = true },
        { workspace = "2", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "3", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "4", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "5", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "6", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "7", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "8", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "9", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
        { workspace = "10", monitor = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622" },
    },
}
