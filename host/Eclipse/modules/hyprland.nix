{ pkgs, lib, ... }:
let
  hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };
  wallpaper = pkgs.fetchurl {
    name = "miku_wallpaper.jpg";
    url = "https://c.lair.moe/pub/miku_wallpaper.jpeg?raw";
    hash = "sha256-inK4X5KzQk5FHwDw2DYy43nm7XtXlC6I0S1PkYUv+3w=";
  };
in {
  wayland.windowManager.hyprland.settings = {
    # Keep the animated wallpaper visible through the panel's translucent surface.
    layer_rule = [
      {
        match.namespace = "^waybar$";
        blur = true;
        # Blur the glass, but exclude its low-alpha CSS shadow from the mask.
        ignore_alpha = 0.2;
        xray = true;
      }
      {
        match.namespace = "^walker$";
        blur = true;
        ignore_alpha = 0.08;
        xray = true;
      }
    ];

    monitor = [
      {
        output = "DP-3";
        mode = "2560x1440@100";
        position = "0x0";
        scale = 1;
      }
      {
        output = "HDMI-A-1";
        mode = "preferred";
        position = "-1080x0";
        scale = 1;
        transform = 1;
      }
    ];

    workspace_rule = [
      { workspace = "1"; monitor = "DP-3"; default = true; }
      { workspace = "10"; monitor = "HDMI-A-1"; default = true; }
    ];

    on = [
      (hyprLua.onStart [
        "hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'"
        "${lib.getExe pkgs.swww} img -o HDMI-A-1 ${wallpaper}"
        "${lib.getExe pkgs.linux-wallpaperengine} ~/.local/share/wpe/wallpaper --assets-dir ~/.local/share/wpe/assets --screen-root DP-3 --noautomute"
      ])
    ];
  };
}
