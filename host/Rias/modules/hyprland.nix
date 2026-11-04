{ ... }: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "DP-3";
        mode = "3440x1440@165";
        position = "auto-right";
        scale = 1;
      }
      {
        output = "HDMI-A-1";
        disabled = true;
      }
    ];

  };
}
