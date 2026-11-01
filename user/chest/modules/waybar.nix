{
  osConfig,
  config,
  inputs,
  pkgs,
  lib,
  ...
 }: let
  mikuFrost = osConfig.networking.hostName == "Eclipse";
in {
  home.packages = with pkgs; [
    font-awesome
    nerd-fonts.symbols-only
    playerctl
    cava
    pulsemixer
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    package = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        mv subprojects/cava-1.0.0 subprojects/libcava
      '';
    });

    settings.mainBar = {
      modules-center = [
        "group/left"
        "group/center"
        "group/right"
      ];


      "group/left" = {
        orientation = "inherit";
        modules = [
          "hyprland/workspaces"
          "custom/sep-left"
          "hyprland/language"
          "keyboard-state"
        ];
      };

      "group/center" = {
        orientation = "inherit";
        modules = [
          "cava"
          "mpris"
        ];
      };

      "group/right" = {
        orientation = "inherit";
        modules = [
          "tray"
          "custom/sep-left"
          "group/system"
          "custom/sep-left"
          "pulseaudio"
          "custom/sep-left"
          "battery"
        ] ++ lib.optional mikuFrost "custom/sep-battery" ++ [
          "clock"
        ];
      };


      "hyprland/workspaces" = lib.optionalAttrs mikuFrost {
        tooltip = false;
      };

      tray = lib.optionalAttrs mikuFrost {
        tooltip = false;
      };

      cava = {
        bars = 9;
        bar_delimiter = 0;
        stereo = false;
        input_delay = 0;
        format-icons = [" " "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
      };

      clock = {
        tooltip = false;
        interval = 5;
        format = "{:L%d %b - %H:%M %a}";
      };

      pulseaudio = {
        tooltip = !mikuFrost;
        format = "{icon} {volume}%";
        format-icons = {
          headphone =  "";
          hands-free =  "";
          headset =  "";
          phone =  "";
          phone-muted =  "";
          portable =  "";
          car =  "";
          default =  ["" ""];
        };
        on-click = "ghostty --title=pulsemixer -e pulsemixer";
      };

      mpris = {
        tooltip = !mikuFrost;
        format = "{dynamic}";
        dynamic-len = if osConfig.host.laptop then 16 else 32;
        dynamic-order = [ "title" "artist" "album" ];
      };

      battery = {
        tooltip = !mikuFrost;
        interval = 5;
        states = {
          warning = 30;
          critical = 15;
        };
        format = if mikuFrost then "{icon} {capacity}%" else "{icon} {capacity}% | ";
        format-icons = {
          default = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          charging = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
        };
      };

      "custom/sep-left" = {
        format = " | ";
        tooltip = false;
      };

      # Follow battery visibility; the divider has no hover or click target.
      "custom/sep-battery" = {
        format = " {} ";
        exec = "printf '|'";
        tooltip = false;
        exec-if = "for battery in /sys/class/power_supply/*; do test \"$(cat \"$battery/type\" 2>/dev/null)\" = Battery && exit 0; done; exit 1";
        interval = 5;
      };

      "keyboard-state" = {
        tooltip = !mikuFrost;
        capslock = true;
        format = "{icon}";
        format-icons = {
          locked = "CAPS";
          unlocked = "";
        };
      };

      "hyprland/language" = {
        tooltip = !mikuFrost;
        format-en = "en";
        format-ru = "ru";
      };

      "group/system" = {
        orientation = "inherit";
          drawer = {
            transition-duration = 500;
            transition-left-to-right = false;
          };
          modules = [
            "network"
            "custom/mem"
            "cpu"
            "temperature"
          ];
      };

      network = {
        tooltip = !mikuFrost;
        format = "{ifname}";
        format-wifi = " {essid} ({signalStrength}%)";
        format-ethernet = "{ifname}";
        format-disconnected = "";
        tooltip-format = "{ipaddr}";
        max-length = 50;
        on-click = "ghostty --title=wifitui -e wifitui";
      };

      "custom/weather" = {
        format = "{}";
        tooltip = true;
        interval = 1800;
        exec = "python3 $HOME/.config/waybar/scripts/wttr.py";
        return-type = "json";
      };

      "custom/mem" = {
        format = "{} ";
        interval = 3;
        exec = "free -h | awk '/Mem:/{printf $3}'";
        tooltip = false;
      };

      cpu = {
        tooltip = !mikuFrost;
        interval = 2;
        format = "{usage}% ";
        min-length = 6;
      };

      temperature = {
        hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = ["" "" "" "" ""];
        tooltip = false;
      };
    };

    style = let
      colors = config.lib.stylix.colors.withHashtag;
      accent = colors.${config.stylix.accent};
      themed = frost: original: if mikuFrost then frost else original;
      scssFile = pkgs.writeText "waybar.scss" /*scss*/ ''
        window#waybar {
          background: transparent;
          color: ${colors.base05};
          font-weight: bold;
          font-size: .85em;
          & > * { padding: ${themed "0 12px 14px" "0 0 6px 0"}; }
        }

        ${lib.optionalString mikuFrost /*scss*/ ''
          // Only the centered island paints a surface or a shadow.
          window#waybar,
          window#waybar > box {
            background: transparent;
            background-image: none;
            border: none;
            box-shadow: none;
          }
        ''}

        .modules-center {
          background: ${themed "rgba(${colors.base01}, 0.58)" "${colors.base01}CC"};
          border: none;
          border-radius: ${themed "22px" "12px"};
          padding: 10px;
          box-shadow: ${themed "0 3px 8px rgba(0, 0, 0, 0.18)" "5px 5px 10px rgba(0, 0, 0, 0.4)"};
        }

        #left,
        #right,
        #center {
          background: ${themed "rgba(40, 59, 79, 0.68)" colors.base02};
          padding: 0 2px;
          margin: 0 8px;
          border-radius: ${themed "12px" "8px"};
        }
        #left { margin-left: 0; }
        #right { margin-right: 0; }

        ${lib.optionalString mikuFrost /*scss*/ ''
          // Keep hover surfaces inside the rounded groups.
          #language, #keyboard-state, #keyboard-state label,
          #cava, #mpris, #tray widget, #tray widget > image,
          #network, #custom-mem, #cpu, #temperature,
          #pulseaudio, #battery, #clock {
            border-radius: 10px;
          }

          #network, #custom-mem, #cpu, #temperature,
          #pulseaudio, #battery, #clock {
            padding-left: 6px;
            padding-right: 6px;
          }

          // Reserve the same width in active, inactive and hover states.
          #workspaces button {
            box-shadow: none;
            text-shadow: none;
            background-image: none;
          }

          tooltip {
            color: ${colors.base05};
            background: rgba(25, 37, 52, 0.94);
            border: 2px solid rgba(67, 214, 205, 0.38);
            border-radius: ${themed "12px" "8px"};
          }
          tooltip label { padding: 6px; }
        ''}

        #clock { padding-right: ${themed "6px" "10px"}; }

        #cava { padding: 0 10px; color: ${themed accent colors.base05}; }

        #custom-sep-left,
        #custom-sep-battery {
          color: ${themed "rgba(147, 168, 186, 0.38)" colors.base05};
          background: transparent;
        }

        #language { padding: 8px; }

        #workspaces button {
          color: ${themed colors.base04 colors.base05};
          padding: 0 2px;
          border-radius: 999px;
          border: 1pt solid transparent;
          min-width: ${themed "25px" "20px"};

          &:hover { background: ${themed "rgba(67, 214, 205, 0.12)" colors.base03}; }

          &.active {
            background: ${accent};
            color: ${colors.base00};
            min-width: 25px;

            &:hover {
              border-color: ${themed "transparent" accent};
              background: ${themed "rgba(67, 214, 205, 0.12)" colors.base03};
              color: ${accent};
            }
          }
        }

        #mpris {
          border-radius: ${themed "10px" "8px"};
          // Do not leave a styled placeholder when the player has no text.
          padding: ${themed "0" "4px"};
          border: none;
          &:hover { background: ${themed "rgba(67, 214, 205, 0.12)" colors.base03}; }
          &.playing {
            border: ${themed "none" "2px solid ${accent}"};
            padding: ${themed "0" "2px"};
            color: ${themed colors.base0E colors.base05};
          }
        }

        ${if mikuFrost then /*scss*/ ''
          // Each SNI item is one event box containing one image. Paint it once.
          #tray > widget {
            border: none;
            border-radius: 10px;
            padding: 0;
            background: transparent;
          }
          #tray > widget:hover {
            background: rgba(67, 214, 205, 0.12);
          }
          #tray > widget > image {
            padding: 8px;
            margin: 0;
            background: transparent;
          }
          #tray > widget.needs-attention {
            background: rgba(245, 171, 130, 0.16);
          }
        '' else /*scss*/ ''
        #tray {
          widget {
            border: 1pt solid transparent;
            &:hover { background: ${themed "rgba(67, 214, 205, 0.12)" colors.base03}; }
            & > image { padding: 8px; }
          }

          & > .passive { border-color: ${colors.base03}; }
          & > .needs-attention { border-color: ${colors.base09}; }
        }

        ''}

        #pulseaudio {
          &:hover { background: ${themed "rgba(67, 214, 205, 0.12)" colors.base03}; }
          &.muted {
            background: ${colors.base08};
            color: ${colors.base01};

            &:hover {
              color: ${colors.base08};
              background: ${themed "rgba(67, 214, 205, 0.12)" colors.base03};
            }
          }
        }

        #network {
          &:hover { background: ${themed "rgba(67, 214, 205, 0.12)" colors.base02}; }
          &.disconnected {
            color: ${colors.base00};
            background: ${colors.base08};
          }
        }

        #system .drawer-child > * {
          margin-right: 4px;
        }

        #keyboard-state label.locked {
          color: ${colors.base08};
        }

        #battery {
          &.plugged { color: ${colors.base0D}; }
          &.charging { color: ${colors.base0B}; }
          &:not(.charging) {
            &.warning {
              color: ${colors.base00};
              background-color: ${colors.base09};
            }
            &.critical {
              background-color: ${colors.base08};
              color: ${colors.base00};
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
            }
          }
          &.full {
            color: ${colors.base00};
            background: ${colors.base0B};
          }
        }

      	@keyframes blink {
          to {
            background-color: ${colors.base00};
            color: ${colors.base08};
          }
        }
      '';

      cssFile = pkgs.runCommand "waybar.css" {
        nativeBuildInputs = [ pkgs.dart-sass ];
      } "sass ${scssFile} $out";
    in builtins.readFile cssFile;
  };
}
