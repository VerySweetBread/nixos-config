{ lib, ... }:
let
  hyprLua = import ./hyprland/lua.nix { inherit lib; };
in {
  services = {
    walker = {
      enable = true;
      systemd.enable = true;
    };

    elephant.enable = true;
  };

  wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.bind "SUPER + D" (hyprLua.exec "walker"))
  ];
}
