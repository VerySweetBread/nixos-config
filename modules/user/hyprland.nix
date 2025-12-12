{ pkgs, lib, config, osConfig, inputs, username, ... }: let
  optImport = path: lib.optional (builtins.pathExists path) path;
  hostname = osConfig.networking.hostName;
in {
  imports =
    optImport ../../host/${hostname}/modules/hyprland.nix ++
    optImport ../../user/${username}/modules/hyprland.nix;

  home.packages = with pkgs; [
    ghostty
    pamixer
    clipse
    wl-clipboard
    wl-clip-persist
    xclip
  ];

  wayland.windowManager.hyprland = let
    colors = config.lib.stylix.colors;
  in {
    enable = true;
    xwayland.enable = true;

    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
      # hyprbars  # Version mismatch
    ];

    settings = {
      "$mainMod" = "SUPER";

      ecosystem = {
        no_donation_nag = true;
        no_update_news = true;
      };

      env = [
        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland"

        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"

        "XCURSOR_SIZE, ${toString config.stylix.cursor.size}"
        "XCURSOR_THEME, ${config.stylix.cursor.name}"

        "XDG_SCREENSHOTS_DIR,~/screens"
      ];

      cursor.no_hardware_cursors = true;

      debug = {
        disable_logs = false;
        enable_stdout_logs = true;
      };

      misc = {
        focus_on_activate = true;
      };

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:caps_toggle";
        numlock_by_default = true;

        follow_mouse = 1;

        touchpad = {
          natural_scroll = false;
        };

        sensitivity = 0;
      };

      gestures = {
        workspace_swipe_invert = true;
        workspace_swipe_distance = 200;
        workspace_swipe_forever = true;
      };

      gesture = [
        "3, horizontal, workspace"
      ];

      windowrule = [
        "float, class:^(imv)$"
        "float, class:^(feh)$"
        "float, class:^(mpv)$"
        "float, title:^(Список друзей)"
        "move onscreen cursor -50% -50%, class:^(xdragon)$"
        "float, title:(nmtui)"
        "float, title:(pulsemixer)"
        "float, title:(clipse)"
        "size 622 652, title:(clipse)"
      ];

      exec-once = lib.mkBefore [
        "systemctl --user start plasma-polkit-agent"
        "${lib.getExe' pkgs.swww "swww-daemon"}"
        "wl-clip-persist --clipboard both"
        "clipse -listen"
        "${lib.getExe' pkgs.udiskie "udiskie"}"
      ];

      bind = [
        "$mainMod, V, exec, ghostty --title=clipse -e clipse"

        "$mainMod, Return, exec, ghostty"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, ghostty -e sh -c yazi"
        "$mainMod, F, togglefloating,"
        "$mainMod, D, exec, fuzzel"
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
        "$mainMod, F3, exec, ${lib.getExe pkgs.brightnessctl} -d *::kbd_backlight set +33%"
        "$mainMod, F2, exec, ${lib.getExe pkgs.brightnessctl} -d *::kbd_backlight set 33%-"

        # Volume and Media Control
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -m"
        ", XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause"

        ", XF86Explorer, exec, ghostty -e sh -c yazi"
        ", XF86Mail, exec, thunderbird"
        ", XF86WWW, exec, google-chrome-stable"  # TODO: Replace hard-code to some variable

        # Brightness control
        ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 5%- "
        ", XF86MonBrightnessUp,   exec, ${lib.getExe pkgs.brightnessctl} set +5% "
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5 "
        ", XF86AudioLowerVolume, exec, pamixer -d 5 "
      ];

      bindc = [
        ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} position 5-"
        ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} position 5+"
      ];

      bindo = [
        ", XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous"
        ", XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next"
      ];

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
