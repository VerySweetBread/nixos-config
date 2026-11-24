{ config, lib, pkgs, ... }:
let
  specialCustom = builtins.toJSON [ {
    key = "daemons";
    label = "Daemons";
    glyph = "build";
    on = true;
    apps = "";
  } ];
in {
  lucid.keybindSeed = ./lucid-keybinds.json;
  lucid.prefsSeed = pkgs.writeText "sweetbread-lucid-prefs.json" (builtins.toJSON (
    (builtins.fromJSON (builtins.readFile ./lucid-prefs.json)) // {
      specialCustom = specialCustom;
    }
  ));
  lucid.startWallpaper = true;
  lucid.installWallpaperSupport = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        before_sleep_cmd = "${lib.getExe' pkgs.quickshell "qs"} ipc call lock lock; ${pkgs.coreutils}/bin/sleep 1";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 120;
          on-timeout = "${lib.getExe pkgs.brightnessctl} -s set 10%";
          on-resume = "${lib.getExe pkgs.brightnessctl} -r";
        }
        {
          timeout = 600;
          on-timeout = "${lib.getExe' pkgs.quickshell "qs"} ipc call lock lock";
        }
        {
          timeout = 900;
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };

  systemd.user.services.lucid-lock-on-login = {
    Unit = {
      Description = "Lock Sweetbread's session after Lucid starts";
      Requires = [ "lucid.service" ];
      After = [ "lucid.service" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "lucid-lock-on-login" ''
        for attempt in $(${pkgs.coreutils}/bin/seq 1 20); do
          if ${lib.getExe' pkgs.quickshell "qs"} ipc call lock lock; then
            exit 0
          fi
          ${pkgs.coreutils}/bin/sleep 0.5
        done
        echo "Lucid lock IPC did not become ready after session start" >&2
        exit 1
      '';
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  lucid.managedFiles = {
    "${config.home.homeDirectory}/.config/quickshell/Agenda.qml" = ./Agenda.qml;
    "${config.home.homeDirectory}/.config/quickshell/CalendarSource.qml" = ./CalendarSource.qml;
    "${config.home.homeDirectory}/.config/quickshell/lucidbar/ClockCalendar.qml" = ./ClockCalendar.qml;
    "${config.home.homeDirectory}/.config/quickshell/thunderbird-calendar.py" = ./thunderbird-calendar.py;
  };

  wayland.windowManager.hyprland.settings.bind = lib.mkForce [];
}
