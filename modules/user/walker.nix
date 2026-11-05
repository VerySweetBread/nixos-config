{ config, lib, osConfig, ... }: let
  hyprLua = import ./hyprland/lua.nix { inherit lib; };
  colors = config.lib.stylix.colors.withHashtag;
  accent = colors.${config.stylix.accent};
in {
  services = {
    walker = {
      enable = true;
      systemd.enable = true;

      theme = {
        name = "stylix";
        # Follow Walker's default CSS structure so provider layouts keep their styling.
        # https://github.com/abenz1267/walker/blob/master/resources/themes/default/style.css
        style = ''
          @define-color window_bg_color ${colors.base00};
          @define-color surface_color ${colors.base01};
          @define-color border_color ${colors.base03};
          @define-color accent_bg_color ${accent};
          @define-color theme_fg_color ${colors.base05};
          @define-color error_bg_color ${colors.base08};
          @define-color error_fg_color ${colors.base00};

          * {
            all: unset;
          }

          popover {
            background: @surface_color;
            border: 1px solid @border_color;
            border-radius: 18px;
            padding: 10px;
            font-family: "${config.stylix.fonts.sansSerif.name}";
            font-size: ${toString config.stylix.fonts.sizes.applications}pt;
          }

          .box-wrapper {
            box-shadow:
              0 19px 38px rgba(0, 0, 0, 0.3),
              0 15px 12px rgba(0, 0, 0, 0.22);
            background: @window_bg_color;
            border: 1px solid @border_color;
            border-radius: 20px;
            padding: 20px;
            font-family: "${config.stylix.fonts.sansSerif.name}";
            font-size: ${toString config.stylix.fonts.sizes.applications}pt;
          }

          .normal-icons { -gtk-icon-size: 16px; }
          .large-icons { -gtk-icon-size: 32px; }
          scrollbar { opacity: 0; }

          .search-container { border-radius: 10px; }

          .input {
            caret-color: @theme_fg_color;
            background: @surface_color;
            padding: 10px;
            color: @theme_fg_color;
          }

          .input placeholder { opacity: 0.5; }
          .input selection { background: ${colors.base02}; }

          .preview-box,
          .elephant-hint,
          .placeholder,
          .list { color: @theme_fg_color; }

          .item-box {
            border-radius: 10px;
            padding: 10px;
          }

          .item-quick-activation {
            background: alpha(@accent_bg_color, 0.25);
            border-radius: 5px;
            padding: 10px;
          }

          child:selected .item-box,
          row:selected .item-box { background: alpha(@accent_bg_color, 0.25); }

          .item-subtext {
            font-size: 12px;
            opacity: 0.5;
          }

          .providerlist .item-subtext {
            font-size: unset;
            opacity: 0.75;
          }

          .item-image-text { font-size: 28px; }

          .preview {
            border: 1px solid alpha(@accent_bg_color, 0.25);
            border-radius: 10px;
            color: @theme_fg_color;
          }

          .calc .item-text,
          .symbols .item-image,
          .todo.urgent { font-size: 24px; }

          .todo.done .item-text-box { opacity: 0.25; }
          .todo.active { font-weight: bold; }
          .bluetooth.disconnected { opacity: 0.5; }
          .preview .large-icons { -gtk-icon-size: 64px; }

          .keybinds {
            padding-top: 10px;
            border-top: 1px solid @border_color;
            font-size: 12px;
            color: @theme_fg_color;
          }

          .keybind-button { opacity: 0.5; }
          .keybind-button:hover { opacity: 0.75; }
          .keybind-bind {
            text-transform: lowercase;
            opacity: 0.35;
          }

          .keybind-label {
            padding: 2px 4px;
            border-radius: 4px;
            border: 1px solid @theme_fg_color;
          }

          .error {
            padding: 10px;
            background: @error_bg_color;
            color: @error_fg_color;
          }

          :not(.calc).current { font-style: italic; }

          .preview-content.archlinuxpkgs,
          .preview-content.dnfpackages,
          .preview-content.aptpackages {
            font-family: "${config.stylix.fonts.monospace.name}";
          }
        '' + lib.optionalString (config.home.username == "chest" && osConfig.networking.hostName == "Eclipse") ''
          /* Keep the existing layout; let the compositor blur the wallpaper. */
          window { background: transparent; }
          .box-wrapper {
            background: alpha(@surface_color, 0.62);
            border: 2px solid alpha(@accent_bg_color, 0.38);
            padding: 19px;
            box-shadow: none;
          }
          .input {
            background: alpha(${colors.base02}, 0.42);
            border-radius: 10px;
          }
          popover {
            background: alpha(@surface_color, 0.86);
            border: 2px solid alpha(@accent_bg_color, 0.38);
            padding: 9px;
          }

          /* Paint only the rounded item, never both its row and child. */
          child, row,
          child:hover, row:hover,
          child:selected, row:selected {
            background: transparent;
            border-radius: 10px;
          }
          child:hover .item-box,
          row:hover .item-box {
            background: alpha(@accent_bg_color, 0.12);
          }
          child:selected .item-box,
          row:selected .item-box {
            background: alpha(@accent_bg_color, 0.25);
          }
        '';
      };
    };

    elephant.enable = true;
  };

  xdg.configFile = lib.optionalAttrs (config.home.username == "chest") {
    "elephant/desktopapplications.toml".text = ''
      history_when_empty = true
    '';
  };

  lucidHyprlandBinds = [
    (hyprLua.bind "SUPER + D" (hyprLua.execLauncher "qs ipc call launcher toggle"))
  ];
}
