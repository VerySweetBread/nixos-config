{ pkgs, lib, config, collection, swww_flags, inputs }: {
  home.packages = with pkgs; [
    kitty
    pamixer
    wofi
    clipse
    grimblast
    wl-clipboard
    cliphist
  ];

  wayland.windowManager.hyprland =
  let
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
      url = "https://wallhaven.cc/api/v1/collections/${collection}"
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
        system(f"${lib.getExe pkgs.swww} img {folder}/{filename} ${swww_flags}")
    '';

    clipsync = pkgs.writers.writeBash "clipsync" ''
      while ${lib.getExe pkgs.clipnotify}; do
        ${lib.getExe pkgs.xclip} -q -sel clip -t image/png -o > /dev/null && \
          ${lib.getExe pkgs.xclip} -sel clip -t image/png -o | wl-copy
        ${lib.getExe pkgs.xclip} -q -sel clip -o > /dev/null && \
          ${lib.getExe pkgs.xclip} -sel clip -o | wl-copy
      done
    '';
  in {
    enable = true;
    xwayland.enable = true;
    
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
      hyprbars
    ];

    settings = {
      "$mainMod" = "SUPER";

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "GBM_BACKEND,nvidia"

        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland"

        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"

        "WLR_NO_HARDWARE_CURSORS,1"
        "XCURSOR_SIZE,36"

        "XDG_SCREENSHOTS_DIR,~/screens"
      ];

      cursor.no_hardware_cursors = true;

      debug = {
        disable_logs = false;
        enable_stdout_logs = true;
      };

      input = {
        kb_layout = "us,ru";
        kb_variant = "lang";
        kb_options = "grp:caps_toggle";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      windowrule = [
        "float, ^(imv)$"
        "float, ^(feh)$"
        "float, ^(mpv)$"
        "float, ^(nmtui)$"
        "float, title:^(Список друзей)"
        "move onscreen cursor -50% -50%, ^(xdragon)$"
      ];

      windowrulev2 = [
        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
      ];

      exec-once = [
        "systemctl --user start plasma-polkit-agent"
        "${lib.getExe' pkgs.swww "swww-daemon"}"
        "${lib.getExe wallpaper_changer}"
        "${clipsync}"
        "clipse -listen"
        "${lib.getExe' pkgs.udiskie "udiskie"}"
      ];

      bind = [
        "$mainMod, V, exec, kitty --class clipse -e clipse"

        "$mainMod, Return, exec, kitty"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, kitty -e sh -c yazi"
        "$mainMod, F, togglefloating,"
        "$mainMod, D, exec, wofi --show drun"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, J, togglesplit, # dwindle"

        # Move focus with mainMod + arrow keys
        "$mainMod, left,  movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up,    movefocus, u"
        "$mainMod, down,  movefocus, d"

        # Moving windows
        "$mainMod SHIFT, left,  swapwindow, l"
        "$mainMod SHIFT, right, swapwindow, r"
        "$mainMod SHIFT, up,    swapwindow, u"
        "$mainMod SHIFT, down,  swapwindow, d"

        # Window resizing                     X  Y
        "$mainMod CTRL, left,  resizeactive, -60 0"
        "$mainMod CTRL, right, resizeactive,  60 0"
        "$mainMod CTRL, up,    resizeactive,  0 -60"
        "$mainMod CTRL, down,  resizeactive,  0  60"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

        "$mainMod SHIFT, F, fullscreen"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Keyboard backlight
        "$mainMod, F3, exec, brightnessctl -d *::kbd_backlight set +33%"
        "$mainMod, F2, exec, brightnessctl -d *::kbd_backlight set 33%-"

        # Volume and Media Control
        ", XF86AudioRaiseVolume, exec, pamixer -i 5 "
        ", XF86AudioLowerVolume, exec, pamixer -d 5 "
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -m"
        
        # Brightness control
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%- "
        ", XF86MonBrightnessUp, exec, brightnessctl set +5% "

        # Waybar
        "$mainMod, B, exec, pkill -SIGUSR1 waybar"
        #"$mainMod, W, exec, pkill -SIGUSR2 waybar"

        "$mainMod, W, exec, ${lib.getExe wallpaper_changer}"
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
