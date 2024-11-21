{ pkgs, lib, config, inputs, ... }: {
  imports = [(
    import ../../../patterns/hyprland.nix {
      inherit lib;
      inherit pkgs;
      inherit config;
      inherit inputs;
      collection = "sweetbread/1764377";
      swww_flags = "--transition-type center";
    }
  )];

  wayland.windowManager.hyprland = let
    colors = config.lib.stylix.colors;
  in {
    settings = {
      monitor = [
        "DP-3, 3440x1440@165.00Hz, auto-right, 1"
        # "HDMI-A-1, 3840x2160@60.00Hz, auto-left, 2"
        "HDMI-A-1, disabled"
        ",preferred,auto,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 3;
        "col.active_border" = "rgba(${colors.base0C}ee) rgba(${colors.base0B}ee) 45deg";
        "col.inactive_border" = "rgba(${colors.base05}aa)";

        layout = "dwindle";
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 16;
          passes = 2;
          new_optimizations = true;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows,     1, 7,  myBezier"
          "windowsOut,  1, 7,  default, popin 80%"
          "border,      1, 10, default"
          "borderangle, 1, 8,  default"
          "fade,        1, 7,  default"
          "workspaces,  1, 6,  default"
        ];
      };

      dwindle = {
        pseudotile = true;
        smart_split = true;
      };

      master.new_status = "master";

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_invert = true;
        workspace_swipe_distance = 200;
        workspace_swipe_forever = true;
      };

      misc = {
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        enable_swallow = true;
        render_ahead_of_time = false;
        disable_hyprland_logo = false;
      };

      bind = [
        "    , Print, exec, grimblast --notify --freeze copy output"
        "CTRL, Print, exec, grimblast --notify --freeze copy area"
        "ALT , Print, exec, grimblast --notify --freeze copy active"
      ];
    };
  };
}
