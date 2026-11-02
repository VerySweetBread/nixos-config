{ ... }: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622";
        mode = "3440x1440@120";
        position = "1920x0";
        scale = 1;
        cm = "srgb";
        supports_hdr = -1;
      }
      {
        output = "desc:Samsung Electric Company SAMSUNG 0x01000E00";
        disabled = true;
        mode = "1920x1080@60";
        position = "0x0";
        scale = 1;
      }
    ];

  };
}
