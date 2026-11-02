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

  lucid.managedFiles = {
    "${config.home.homeDirectory}/.config/quickshell/Agenda.qml" = ./Agenda.qml;
    "${config.home.homeDirectory}/.config/quickshell/CalendarSource.qml" = ./CalendarSource.qml;
    "${config.home.homeDirectory}/.config/quickshell/lucidbar/ClockCalendar.qml" = ./ClockCalendar.qml;
    "${config.home.homeDirectory}/.config/quickshell/thunderbird-calendar.py" = ./thunderbird-calendar.py;
  };

  wayland.windowManager.hyprland.settings.bind = lib.mkForce [];
}
