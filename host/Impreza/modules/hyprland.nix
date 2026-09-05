{ pkgs, lib, ... }:
let
  hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };
  wallpaper = pkgs.fetchurl {
    name = "miku_wallpaper.jpg";
    url = "https://c.lair.moe/pub/miku_wallpaper.jpeg?raw";
    hash = "sha256-inK4X5KzQk5FHwDw2DYy43nm7XtXlC6I0S1PkYUv+3w=";
  };
in {
  wayland.windowManager.hyprland.settings.on = [
    (hyprLua.onStart [
      "${lib.getExe pkgs.swww} img -o eDP-1 ${wallpaper}"
    ])
  ];
}
