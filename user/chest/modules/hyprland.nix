{ pkgs, lib, config, ... }:
let
  colors = config.lib.stylix.colors;
  accent = colors.${config.stylix.accent};
  hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };
in {
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = lib.mkForce {
          colors = [
            "rgba(${accent}ee)"
            "rgba(${colors.base0C}ee)"
          ];
          angle = 45;
        };
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

      animations.enabled = true;

      dwindle.smart_split = true;
      master.new_status = "master";

      misc = {
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        enable_swallow = true;
      };
    };

    curve = {
      _args = [
        "myBezier"
        {
          type = "bezier";
          points = [
            [ 0.05 0.9 ]
            [ 0.1 1.05 ]
          ];
        }
      ];
    };

    animation = [
      { leaf = "windows"; enabled = true; speed = 7; bezier = "myBezier"; }
      { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 80%"; }
      { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
      { leaf = "borderangle"; enabled = true; speed = 8; bezier = "default"; }
      { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; }
      { leaf = "workspaces"; enabled = true; speed = 6; bezier = "default"; }
    ];
  };

  lucidHyprlandBinds = [
    (hyprLua.bind "SUPER + SHIFT + S" (hyprLua.exec ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.swappy} -f -''))
  ];
}
