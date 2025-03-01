{ config, pkgs, lib, ... }:

lib.mkIf config.programs.hyprlock.enable {
  wayland.windowManager.hyprland.settings.exec-once = [ "hyprlock" ];

  programs.hyprlock = let
    image = pkgs.fetchurl {
      name = "lock_background.jpg";
      url = "https://w.wallhaven.cc/full/kx/wallhaven-kxwol7.jpg";
      hash = "sha256-wRFs/Inw1wEzF5UKFn/o6e/xH5ZJ3SVNxxno+mDx2Fs=";
    };
  in {
    settings = {
      background = {
        path = lib.mkForce "${image}";
        blur_passes = 0;
        blur_size = 7;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      shape = {
        size = "360, 60";
        color = "rgba(17, 17, 17, 1.0)";
        rounding = -1;
        border_size = 8;
        border_color = "rgba(0, 207, 230, 1.0)";
        rotate = 0;
        xray = false;

        position = "0, 80";
        halign = "center";
        valign = "center";
      };

      label = {
        text = "Hi there, $USER";
        text_align = "center";
        color = "rgba(200, 200, 200, 1.0)";
        font_size = 25;
        font_family = "Noto Sans";
        rotate = 0;

        position = "0, 80";
        halign = "center";
        valign = "center";
      };

      input-field = {
        size = "200, 50";
        outline_thickness = 3;
        dots_size = 0.33;
        dots_spacing = 0.15;
        dots_center = false;
        dots_rounding = -1;
        dots_fade_time = 200;
        font_family = "Noto Sans";
        fade_on_empty = true;
        fade_timeout = 1000;
        placeholder_text = "<i>Input Password...</i>";
        hide_input = false;
        rounding = -1;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        fail_timeout = 2000;
        fail_transition = 300;
        capslock_color = -1;
        numlock_color = -1;
        bothlock_color = -1;
        invert_numlock = false;
        swap_font_color = false;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };
    };
  };
}
