{ pkgs, lib, config, osConfig, inputs, username, ... }:
let
  optImport = path: lib.optional (builtins.pathExists path) path;
  hostname = osConfig.networking.hostName;
  hyprLua = import ./hyprland/lua.nix { inherit lib; };
  inherit (hyprLua) bind bindWithFlags exec onStart;

  direction = {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
  };

  workspaceBinds = lib.concatMap (workspace:
    let
      key = if workspace == 10 then "0" else toString workspace;
      workspaceValue = toString workspace;
    in [
      (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${workspaceValue} })")
      (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${workspaceValue}, follow = false })")
    ]
  ) (lib.range 1 10);
in {
  imports = [
    ./hyprland/zoom.nix
  ] ++
    optImport ../../host/${hostname}/modules/hyprland.nix ++
    optImport ../../user/${username}/modules/hyprland.nix;

  home.packages = with pkgs; [
    ghostty
    pamixer
    clipse
    wl-clipboard
    wl-clip-persist
    xclip
    awww
    wifitui
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    xwayland.enable = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = with inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}; [
      # hyprbars  # Version mismatch
    ];

    settings = {
      config = {
        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
        };

        cursor.no_hardware_cursors = 1;

        debug = {
          disable_logs = false;
          enable_stdout_logs = true;
        };

        general."col.inactive_border" = lib.mkForce "rgba(00000000)";

        decoration = {
          inactive_opacity = lib.mkDefault 0.95;
          border_part_of_window = false;
        };

        misc.focus_on_activate = true;

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:caps_toggle";
          numlock_by_default = true;
          follow_mouse = 1;
          touchpad.natural_scroll = false;
          sensitivity = 0;
        };

        gestures = {
          workspace_swipe_invert = true;
          workspace_swipe_distance = 200;
          workspace_swipe_forever = true;
        };
      };

      env = [
        { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
        { _args = [ "QT_QPA_PLATFORM" "wayland" ]; }
        { _args = [ "QT_QPA_PLATFORMTHEME" "xdgdesktopportal" ]; }
        { _args = [ "GTK_USE_PORTAL" "1" ]; }
        { _args = [ "TDESKTOP_USE_GTK_FILE_DIALOG" "1" ]; }
        { _args = [ "NIXOS_OZONE_WL" "1" ]; }
        { _args = [ "ELECTRON_OZONE_PLATFORM_HINT" "auto" ]; }
        { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
        { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }
        { _args = [ "XCURSOR_SIZE" (toString config.stylix.cursor.size) ]; }
        { _args = [ "XCURSOR_THEME" config.stylix.cursor.name ]; }
        { _args = [ "XDG_SCREENSHOTS_DIR" "~/screens" ]; }
      ];

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      workspace_rule = [
        {
          workspace = "w[t1]";
          gaps_out = 0;
        }
      ];

      window_rule = [
        { match.class = "imv"; float = true; }
        { match.class = "feh"; float = true; }
        { match.class = "mpv"; float = true; }
        { match.title = "Список друзей"; float = true; }
        { match.title = "wifitui"; float = true; }
        { match.title = "pulsemixer"; float = true; }
        { match.title = "clipse"; float = true; }
        { match.title = "clipse"; size = [ 622 652 ]; }
        { match.focus = true; rounding = 0; }
        {
          match = {
            float = false;
            workspace = "w[t1]";
          };
          border_size = 0;
        }
      ];

      on = lib.mkBefore [
        (onStart [
          "systemctl --user start plasma-polkit-agent"
          "${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all"
          "systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY GTK_USE_PORTAL QT_QPA_PLATFORMTHEME TDESKTOP_USE_GTK_FILE_DIALOG NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT"
          "awww-daemon"
          "wl-clip-persist --clipboard both"
          "clipse -listen"
          "${lib.getExe' pkgs.udiskie "udiskie"}"
        ])
      ];

      bind = [
        (bind "SUPER + V" (exec "ghostty --title=clipse -e clipse"))
        (bind "SUPER + RETURN" (exec "ghostty"))
        (bind "SUPER + Q" "hl.dsp.window.close()")
        (bind "SUPER + M" "hl.dsp.exit()")
        (bind "SUPER + E" (exec "ghostty -e sh -c yazi"))
        (bind "SUPER + F" "hl.dsp.window.float({ action = \"toggle\" })")
        (bind "SUPER + P" "hl.dsp.window.pseudo({ action = \"toggle\" })")
        (bind "SUPER + J" "hl.dsp.layout(\"togglesplit\")")
        (bind "SUPER + K" "hl.dsp.layout(\"swapsplit\")")

        (bind "SUPER + LEFT" "hl.dsp.focus({ direction = \"${direction.left}\" })")
        (bind "SUPER + RIGHT" "hl.dsp.focus({ direction = \"${direction.right}\" })")
        (bind "SUPER + UP" "hl.dsp.focus({ direction = \"${direction.up}\" })")
        (bind "SUPER + DOWN" "hl.dsp.focus({ direction = \"${direction.down}\" })")

        (bind "SUPER + SHIFT + LEFT" "hl.dsp.window.swap({ direction = \"${direction.left}\" })")
        (bind "SUPER + SHIFT + RIGHT" "hl.dsp.window.swap({ direction = \"${direction.right}\" })")
        (bind "SUPER + SHIFT + UP" "hl.dsp.window.swap({ direction = \"${direction.up}\" })")
        (bind "SUPER + SHIFT + DOWN" "hl.dsp.window.swap({ direction = \"${direction.down}\" })")

        (bind "SUPER + CTRL + LEFT" "hl.dsp.window.resize({ x = -60, y = 0, relative = true })")
        (bind "SUPER + CTRL + RIGHT" "hl.dsp.window.resize({ x = 60, y = 0, relative = true })")
        (bind "SUPER + CTRL + UP" "hl.dsp.window.resize({ x = 0, y = -60, relative = true })")
        (bind "SUPER + CTRL + DOWN" "hl.dsp.window.resize({ x = 0, y = 60, relative = true })")
      ] ++ workspaceBinds ++ [
        (bind "SUPER + SHIFT + F" "hl.dsp.window.fullscreen({ action = \"toggle\", mode = \"fullscreen\" })")
        (bind "SUPER + mouse_down" "hl.dsp.focus({ workspace = \"e-1\" })")
        (bind "SUPER + mouse_up" "hl.dsp.focus({ workspace = \"e+1\" })")

        (bind "SUPER + F3" (exec "${lib.getExe pkgs.brightnessctl} -d *::kbd_backlight set +33%"))
        (bind "SUPER + F2" (exec "${lib.getExe pkgs.brightnessctl} -d *::kbd_backlight set 33%-"))

        (bind "XF86AudioMute" (exec "pamixer -t"))
        (bind "XF86AudioMicMute" (exec "pamixer --default-source -m"))
        (bind "XF86AudioPlay" (exec "${lib.getExe pkgs.playerctl} play-pause"))
        (bind "XF86Explorer" (exec "ghostty -e sh -c yazi"))
        (bind "XF86Mail" (exec "thunderbird"))
        (bind "XF86WWW" (exec "google-chrome-stable"))

        (bind "XF86MonBrightnessDown" (exec "${lib.getExe pkgs.brightnessctl} set 5%-"))
        (bind "XF86MonBrightnessUp" (exec "${lib.getExe pkgs.brightnessctl} set +5%"))

        (bindWithFlags "XF86AudioRaiseVolume" (exec "pamixer -i 5") { repeating = true; })
        (bindWithFlags "XF86AudioLowerVolume" (exec "pamixer -d 5") { repeating = true; })

        (bindWithFlags "XF86AudioPrev" (exec "${lib.getExe pkgs.playerctl} position 5-") { click = true; })
        (bindWithFlags "XF86AudioNext" (exec "${lib.getExe pkgs.playerctl} position 5+") { click = true; })
        (bindWithFlags "XF86AudioPrev" (exec "${lib.getExe pkgs.playerctl} previous") { long_press = true; })
        (bindWithFlags "XF86AudioNext" (exec "${lib.getExe pkgs.playerctl} next") { long_press = true; })

        (bindWithFlags "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (bindWithFlags "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
      ];
    };
  };

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-termfilechooser
    ];

    config = {
      common = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };

      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };
}
