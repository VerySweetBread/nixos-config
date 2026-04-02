{ pkgs, lib, ...}: {
  wayland.windowManager.hyprland = let
    monitor-switcher = pkgs.writers.writeBashBin "monitor_switcher" /*bash*/ ''
      MODE=$1

      case $MODE in
        "tv")
          hyprctl keyword monitor "DP-3, 1920x1080@60, 3840x0, 1"
          hyprctl keyword monitor "HDMI-A-1, 3840x2160@60, 0x0, 1"
          notify-send "TV mode"
        ;;

        "mirror")
          hyprctl keyword monitor "HDMI-A-1, 3840x2160@60, 0x0, 1"
          hyprctl keyword monitor "DP-3, preferred, auto, 1, mirror, HDMI-A-1"
          notify-send "TV-only mode"
        ;;

        "display"|*)
          hyprctl keyword monitor "HDMI-A-1, disable"
          hyprctl keyword monitor "DP-3, 3440x1440@165, 0x0, 1"
          notify-send "Display mode"
        ;;

      esac
    '';
  in {
    settings = {
      monitor = [
        "DP-3, 3440x1440@165, auto-right, 1"
        # "HDMI-A-1, 3840x2160@60, auto-left, 2"
        "HDMI-A-1, disabled"
      ];

      bind = [
        '', XF86Calculator, exec, ghostty --title=pulsemixer -e pulsemixer''

        ''$mainMod, F1, exec, ${lib.getExe monitor-switcher} tv''
        ''$mainMod, F2, exec, ${lib.getExe monitor-switcher} mirror''
        ''$mainMod, F3, exec, ${lib.getExe monitor-switcher}''
      ];
    };
  };
}