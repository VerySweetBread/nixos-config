{ pkgs, lib, config, osConfig, ... }: {
  wayland.windowManager.hyprland = let
    colors = config.lib.stylix.colors;
    accent = colors.${config.stylix.accent};
    hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };

    wallpaper_changer = pkgs.writers.writePython3Bin "wallpaper_changer" {
      libraries = [ pkgs.python3Packages.requests ];
      flakeIgnore = [ "E111" "E121" "E241" "E501" "E701" "E731" ];
    } /*py*/ ''
      import requests as requests
      from random import choice
      from os import listdir, makedirs, remove, replace
      from os.path import exists
      from subprocess import run

      notify_id = None


      def notify(text, progress=None, expire_time=5000):
        global notify_id

        command = [
          "${pkgs.libnotify}/bin/notify-send",
          "--app-name", "wallpaper_changer",
          "--print-id",
          "--expire-time", str(expire_time),
        ]

        if notify_id:
          command.extend(["--replace-id", str(notify_id)])

        if progress is not None:
          command.extend(["--hint", f"int:value:{progress}"])

        command.extend(["Wallpaper", text])

        result = run(command, capture_output=True, text=True, check=False)
        output = result.stdout.strip()
        if output.isdigit():
          notify_id = output


      def download_with_progress(link, destination):
        temporary = f"{destination}.part"
        downloaded = 0
        last_progress = -1

        response = None
        try:
          response = requests.get(link, stream=True)
          response.raise_for_status()
          total = int(response.headers.get("content-length", 0))

          with open(temporary, "wb") as file:
            for chunk in response.iter_content(chunk_size=256 * 1024):
              if not chunk:
                continue

              file.write(chunk)
              downloaded += len(chunk)

              if total <= 0:
                continue

              progress = min(100, downloaded * 100 // total)
              if progress == 100 or progress >= last_progress + 2:
                notify(f"Downloading... {progress}%", progress, 0)
                last_progress = progress

          replace(temporary, destination)
        except Exception:
          if exists(temporary):
            remove(temporary)
          raise
        finally:
          if response is not None:
            response.close()


      folder = "${config.home.homeDirectory}/Wallpapers"
      url = "https://wallhaven.cc/api/v1/collections/sweetbread/${
        if osConfig.networking.hostName == "Rias" then "1764377"
        else "2108577"
      }"
      with open("${config.sops.secrets."tokens/apis/wallhaven".path}") as f:
        token = f.read()

      filename = None
      notify("Updating wallpaper...", 0)

      try:
        response = requests.get(url, params={'apikey': token})
        response.raise_for_status()
        json = response.json()

        wallpaper = choice(json['data'])
        link = wallpaper['path']
        format = wallpaper['file_type']
        id = wallpaper['id']

        if format == "image/jpeg": ext = "jpg"
        else:                      ext = "png"

        filename = f"{id}.{ext}"
        destination = f"{folder}/{filename}"

        if not exists(destination):
          makedirs(folder, exist_ok=True)
          notify("Downloading... 0%", 0, 0)
          download_with_progress(link, destination)
          notify("Downloaded", 100)
        else:
          notify("Using cached wallpaper", 100)

      except requests.exceptions.RequestException:
        notify("Offline mode")
        try:
          filename = choice(listdir(folder))
        except (FileNotFoundError, IndexError):
          notify("Offline mode and wallpaper cache is empty")

      finally:
        if filename is not None:
          notify("Applying wallpaper", 100)
          run([
            "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper/set-wallpaper.sh",
            f"{folder}/{filename}",
          ], check=False)
    '';
  in {
    settings = {
      config = {
        general = {
          gaps_in = 2;
          gaps_out = 10;
          border_size = 3;
          "col.active_border" = lib.mkForce {
            colors = [
              "rgba(${colors.base0C}aa)"
              "rgba(${accent}aa)"
            ];
            angle = 45;
          };
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;
            size = 8;
            passes = 1;
            new_optimizations = true;
          };

          shadow.enabled = false;
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

      workspace_rule = [
        {
          workspace = "2";
          layout = "scrolling";
        }
      ];

      bind = [
        (hyprLua.bind "SUPER + W" (hyprLua.execLauncher "qs ipc call launcher wallpaper"))
        (hyprLua.bind "SUPER + SHIFT + W" (hyprLua.exec "${lib.getExe wallpaper_changer}"))
      ];
    };
  };
}
