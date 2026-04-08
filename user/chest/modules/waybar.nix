{ osConfig, config, pkgs, lib, ... }: {
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
          "clock"
        ];
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
        format = "{dynamic}";
        dynamic-len = if osConfig.host.laptop then 16 else 32;
        dynamic-order = [ "title" "artist" "album" ];
      };

      battery = {
        interval = 5;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}% | ";
        format-icons = {
          default = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          charging = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
        };
      };

      "custom/sep-left" = {
        format = " | ";
        tooltip = false;
      };

      "keyboard-state" = {
        capslock = true;
        format = "{icon}";
        format-icons = {
          locked = "CAPS";
          unlocked = "";
        };
      };

      "hyprland/language" = {
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
        format = "{ifname}";
        format-wifi = " {essid} ({signalStrength}%)";
        format-ethernet = "{ifname}";
        format-disconnected = "";
        tooltip-format = "{ipaddr}";
        max-length = 50;
        on-click = "ghostty --title=nmtui -e nmtui";
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
      accent = colors.base0E;
      scssFile = pkgs.writeText "waybar.scss" /*scss*/ ''
        window#waybar {
          background: transparent;
          color: ${colors.base05};
          font-weight: bold;
          font-size: .85em;
          & > * { padding: 0 0 6px 0; }
        }

        .modules-center {
          background: ${colors.base01}CC;
          border-radius: 12px;
          padding: 10px;
          box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.4);
        }

        #left,
        #right,
        #center {
          background: ${colors.base02};
          padding: 0 2px;
          margin: 0 8px;
          border-radius: 8px;
        }
        #left { margin-left: 0; }
        #right { margin-right: 0; }

        #clock { padding-right: 10px; }

        #cava { padding: 0 10px; }

        #language { padding: 8px; }

        #workspaces button {
          color: ${colors.base05};
          padding: 0 2px;
          border-radius: 999px;
          border: 1pt solid transparent;
          min-width: 20px;

          &:hover { background: ${colors.base03}; }

          &.active {
            background: ${accent};
            color: ${colors.base00};
            min-width: 25px;

            &:hover {
              border-color: ${accent};
              background: ${colors.base03};
              color: ${accent};
            }
          }
        }

        #mpris {
          border-radius: 8px;
          padding: 4px;
          &:hover { background: ${colors.base03}; }
          &.playing {
            border: 2px solid ${accent};
            padding: 2px;
          }
        }

        #tray {
          widget {
            border: 1pt solid transparent;
            &:hover { background: ${colors.base03}; }
            & > image { padding: 8px; }
          }

          & > .passive { border-color: ${colors.base03}; }
          & > .needs-attention { border-color: ${colors.base09}; }
        }

        #pulseaudio {
          &:hover { background: ${colors.base03}; }
          &.muted {
            background: ${colors.base08};
            color: ${colors.base01};

            &:hover {
              color: ${colors.base08};
              background: ${colors.base03};
            }
          }
        }

        #network {
          &:hover { background: ${colors.base02}; }
          &.disconnected {
            color: ${colors.base00};
            background: ${colors.base08};
          }
        }

        #system .drawer-child > * {
          margin-right: 4px
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
