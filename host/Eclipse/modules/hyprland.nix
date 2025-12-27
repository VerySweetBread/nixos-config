{ pkgs, lib, ... }: {
  wayland.windowManager.hyprland = let
    wallpaper = pkgs.fetchurl {
      name = "miku_wallpaper.jpg";
      url = "https://c.lair.moe/pub/miku_wallpaper.jpeg?raw";
      hash = "sha256-inK4X5KzQk5FHwDw2DYy43nm7XtXlC6I0S1PkYUv+3w=";
    };
  in {
    settings = {
      monitor = [
        "DP-3    , 1920x1080@165, 0x0    , 1"
        "HDMI-A-1, preferred    , -1080x0, 1, transform, 1"
      ];

      workspace = [
        "1,  monitor:DP-3,     default:true"
        "10, monitor:HDMI-A-1, default:true"
      ];

      exec-once = [
        "hyprctl dispatch workspace 1"
        "${lib.getExe pkgs.swww} img -o HDMI-A-1 ${wallpaper}"
        "${lib.getExe pkgs.linux-wallpaperengine} ~/.local/share/wpe/wallpaper --assets-dir ~/.local/share/wpe/assets --screen-root DP-3 --noautomute"
      ];
    };
  };
}