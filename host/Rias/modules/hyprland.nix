{ pkgs, lib, ... }:
let
  hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };

  monitor-switcher = pkgs.writers.writeBashBin "monitor_switcher" /*bash*/ ''
    MODE=$1

    case $MODE in
      "tv")
        hyprctl eval 'hl.monitor({ output = "DP-3", mode = "1920x1080@60", position = "3840x0", scale = 1 })'
        hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = 1 })'
        notify-send "TV mode"
      ;;

      "mirror")
        hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = 1 })'
        hyprctl eval 'hl.monitor({ output = "DP-3", mode = "preferred", position = "auto", scale = 1, mirror = "HDMI-A-1" })'
        notify-send "TV-only mode"
      ;;

      "display"|*)
        hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
        hyprctl eval 'hl.monitor({ output = "DP-3", mode = "3440x1440@165", position = "0x0", scale = 1 })'
        notify-send "Display mode"
      ;;
    esac
  '';
in {
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

    bind = [
      (hyprLua.bind "XF86Calculator" (hyprLua.exec "ghostty --title=pulsemixer -e pulsemixer"))
      (hyprLua.bind "SUPER + F1" (hyprLua.exec "${lib.getExe monitor-switcher} tv"))
      (hyprLua.bind "SUPER + F2" (hyprLua.exec "${lib.getExe monitor-switcher} mirror"))
      (hyprLua.bind "SUPER + F3" (hyprLua.exec "${lib.getExe monitor-switcher}"))
    ];
  };
}
