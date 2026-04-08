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
      spacing = 8;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/language"
        "keyboard-state"
        "cava"
      ];

      modules-center = [
        "mpris"
      ];

      modules-right = [
        "tray"
        "group/system"
        "pulseaudio"
        "battery"
        "clock"
      ];

      cava = {
        bars = 14;
        sleep_timer = 5;
        hide_on_silence = true;
        bar_delimiter = 0;
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
        dynamic-len = if osConfig.host.laptop then 32 else 64;
        dynamic-order = [ "title" "artist" "album" ];
      };

      battery = {
        interval = 5;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-icons = {
          default = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          charging = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
        };
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
      radius = "6px";
      scssFile = pkgs.writeText "waybar.scss" /*scss*/ ''
        window#waybar {
          background: transparent;
          color: ${colors.base05};
          border-radius: ${radius};
          font-weight: bold;
          font-size: .85em;

          & > * { padding: 8px; }
        }

        #cava,
        #language,
        #mpris,
        #pulseaudio,
        #network,
        #battery,
        #cpu,
        #temperature,
        #keyboard-state label.locked,
        #custom-mem,
        #clock {
          background: ${colors.base00};
          border-radius: ${radius};
          padding: 8px;
        }

        #workspaces,
        #tray {
          background: ${colors.base00};
          border-radius: ${radius};
        }

        #workspaces button {
          color: ${colors.base05};
          padding: 4px;
          border-radius: ${radius};
          border: 1pt solid transparent;

          &:hover { background: ${colors.base01}; }

          &.active {
            background: ${colors.base0B};
            color: ${colors.base00};

            &:hover {
              border-color: ${colors.base0B};
              background: ${colors.base01};
              color: ${colors.base0B};
            }
          }
        }

        #mpris {
          &:hover { background: ${colors.base01}; }
          &.paused { opacity: .5; }
        }

        #tray {
          widget {
            border: 1pt solid transparent;
            border-radius: ${radius};
            &:hover { background: ${colors.base01}; }
            & > image { padding: 8px; }
          }

          & > .passive { border-color: ${colors.base02}; }
          & > .needs-attention { border-color: ${colors.base09}; }
        }

        #pulseaudio {
          &:hover { background: ${colors.base01}; }
          &.muted {
            background: ${colors.base08};
            color: ${colors.base00};

            &:hover {
              color: ${colors.base08};
              background: ${colors.base01};
            }
          }
        }

        #network {
          &:hover { background: ${colors.base01}; }
          &.disconnected {
            color: ${colors.base00};
            background: ${colors.base08};
          }
        }

        #system .drawer-child > * {
          margin-right: 4px
        }

        #keyboard-state label.locked {
          background-color: ${colors.base00};
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

  wayland.windowManager.hyprland.settings.layerrule = [
    "blur on, match:namespace waybar"
  ];
}
