{
  services = {
    walker = {
      enable = true;
      systemd.enable = true;
    };

    elephant.enable = true;
  };

  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, D, exec, walker"
  ];
}
