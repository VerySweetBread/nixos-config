{ config, pkgs, lib, ... }: let
  c = config.lib.stylix.colors;

  wobSocket = ''"''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wob.sock"'';

  volumeStep = pkgs.writeShellScriptBin "volume-step" /*bash*/ ''
    volume="$(${lib.getExe' pkgs.wireplumber "wpctl"} get-volume @DEFAULT_AUDIO_SINK@)"
    percent="$(printf '%s\n' "$volume" | ${pkgs.gawk}/bin/awk '{print int($2 * 100)}')"

    if printf '%s\n' "$volume" | ${pkgs.gnugrep}/bin/grep -q MUTED; then
      printf '%s muted\n' "$percent" > ${wobSocket}
    else
      printf '%s volume\n' "$percent" > ${wobSocket}
    fi
  '';

  brightnessStep = pkgs.writeShellScriptBin "brightness-step" /*bash*/ ''
    percent="$(${lib.getExe pkgs.brightnessctl} -m | ${lib.getExe' pkgs.coreutils "cut"} -d, -f4 | ${lib.getExe' pkgs.coreutils "tr"} -d '%')"
    printf '%s brightness\n' "$percent" > ${wobSocket}
  '';

  hyprLua = import ./hyprland/lua.nix { inherit lib; };
in {
  systemd.user = {
    services.wob.Install.WantedBy = lib.mkForce [ ];
    sockets.wob.Install.WantedBy = lib.mkForce [ "sockets.target" ];
  };

  services.wob = {
    enable = true;
    systemd = true;

    settings = {
      "" = {
        timeout = 2000;
        max = 100;

        width = 280;
        height = 32;

        border_offset = 0;
        border_size = 2;
        bar_padding = 4;

        anchor = "top center";
        margin = "0 0 0 0";

        overflow_mode = "nowrap";
        orientation = "horizontal";
      };

      "style.volume" = { bar_color = c.base0D; };
      "style.brightness" = { bar_color = c.base0A; };
      "style.muted" = { bar_color = c.base04; };
    };
  };

  wayland.windowManager.hyprland.settings.bind = [
    (hyprLua.bindWithFlags "XF86AudioRaiseVolume" (hyprLua.exec "${lib.getExe volumeStep}") {
      repeating = true;
      locked = true;
    })
    (hyprLua.bindWithFlags "XF86AudioLowerVolume" (hyprLua.exec "${lib.getExe volumeStep}") {
      repeating = true;
      locked = true;
    })
    (hyprLua.bindWithFlags "XF86MonBrightnessUp" (hyprLua.exec "${lib.getExe brightnessStep}") {
      repeating = true;
      locked = true;
    })
    (hyprLua.bindWithFlags "XF86MonBrightnessDown" (hyprLua.exec "${lib.getExe brightnessStep}") {
      repeating = true;
      locked = true;
    })
    (hyprLua.bind "XF86AudioMute" (hyprLua.exec "${lib.getExe volumeStep} mute"))
  ];
}
