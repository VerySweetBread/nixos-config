{ pkgs, lib, config, inputs, ... }: {
  wayland.windowManager.hyprland = let
    colors = config.lib.stylix.colors;

    wallpaper_changer = pkgs.writers.writePython3Bin "wallpaper_changer" {
      libraries = [ pkgs.python3Packages.requests ];
      flakeIgnore = [ "E501" "E111" "E701" "E241" "E731" ];
    } /*py*/ ''
      import requests as requests
      from random import choice
      from os import system, mkdir, listdir
      from os.path import exists

      notify = lambda s: system(f"notify-desktop Wallpaper '{s}'")
      folder = "${config.home.homeDirectory}/Wallpapers"
      url = "https://wallhaven.cc/api/v1/collections/sweetbread/1764377"
      with open("${config.sops.secrets."tokens/apis/wallhaven".path}") as f:
        token = f.read()

      notify("Updating wallpaper!")

      try:
        json = requests.get(url, params={'apikey': token}).json()

        wallpaper = choice(json['data'])
        link = wallpaper['path']
        format = wallpaper['file_type']
        id = wallpaper['id']

        if format == "image/jpeg": ext = "jpg"
        else:                      ext = "png"

        filename = f"{id}.{ext}"

        if not exists(f"{folder}/{filename}"):
          if not exists(folder):
            mkdir(f"{folder}")

          notify("Downloading...")
          with open(f"{folder}/{filename}", 'wb') as f:
            r = requests.get(link)
            f.write(r.content)

      except requests.exceptions.ConnectionError:
        notify("Offline mode")
        filename = choice(listdir(folder))

      finally:
        system(f"${lib.getExe pkgs.swww} img {folder}/{filename} --transition-type center")
    '';
  in {
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = lib.mkForce "rgba(${colors.base0C}ee) rgba(${colors.base0B}ee) 45deg";
        "col.inactive_border" = lib.mkForce "rgba(${colors.base05}aa)";

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

      misc = {
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        enable_swallow = true;
      };

      exec-once = [
        "${lib.getExe wallpaper_changer}"
      ];

      bind = [
        "    , Print, exec, ${lib.getExe pkgs.hyprshot} -z -o ~/Screenshots -m active -m output"
        "CTRL, Print, exec, ${lib.getExe pkgs.hyprshot} -z -o ~/Screenshots -m region"
        "ALT , Print, exec, ${lib.getExe pkgs.hyprshot} -z -o ~/Screenshots -m active -m window"

        "$mainMod, W, exec, ${lib.getExe wallpaper_changer}"
      ];
    };
  };
}
