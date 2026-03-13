{ osConfig, config, pkgs, ... }: {
  home.packages = with pkgs; [
    font-awesome
    playerctl
  ];
  
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      margin = "8";
      spacing = 8;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/language"
        "keyboard-state"
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
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-icons = ["" "" "" "" ""];
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
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname} ";
        format-disconnected = "";
        tooltip-format = "{ifname}";
        tooltip-format-wifi = "{essid} ({signalStrength}%) ";
        tooltip-format-ethernet = "{ifname} ";
        tooltip-format-disconnected = "Disconnected";
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
        # thermal-zone = 2;
        hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
        critical-threshold = 80;
        # format-critical = "{temperatureC}°C {icon}";
        format = "{temperatureC}°C {icon}";
        format-icons = ["" "" "" "" ""];
        tooltip = false;
      };
    };

    style = let
      colors = config.lib.stylix.colors.withHashtag;
      radius = "12px";
    in /* css */ ''
      window#waybar {
        background: transparent;
        color: ${colors.base05};
        border-radius: ${radius};
        font-weight: bold;
        font-size: 1.1em;
      }

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
      }
      #workspaces button:hover {
        background: ${colors.base01};
      }
      #workspaces button.active {
        background: ${colors.base0B};
        color: ${colors.base00};
      }
      #workspaces button.active:hover {
        border-color: ${colors.base0B};
        background: ${colors.base01};
        color: ${colors.base0B};
      }

      #mpris:hover {
        background: ${colors.base01};
      }
      #mpris.paused {
        opacity: .5;
      }

      #tray widget {
        border: 1pt solid transparent;
        border-radius: ${radius};
      }
      #tray widget:hover {
        background: ${colors.base01};
      }
      #tray widget>image {
        padding: 8px;
      }
      #tray > .passive {
        border-color: ${colors.base02};
      }
      #tray > .needs-attention {
        border-color: ${colors.base09};
      }

      #pulseaudio:hover,
      #pulseaudio.muted:hover {
        background: ${colors.base01};
      }
      #pulseaudio.muted {
        background: ${colors.base08};
        color: ${colors.base00};
      }

      #network:hover {
        background: ${colors.base01};
      }

      #system .drawer-child > * {
        margin-right: 4px
      }

      #keyboard-state label.locked {
        background-color: ${colors.base00};
        color: ${colors.base08};
      }

      #battery.charging {
        color: ${colors.base0B};
      }
      #battery.warning:not(.charging) {
        color: ${colors.base00};
        background-color: ${colors.base09};
      }
      #battery.critical:not(.charging) {
        background-color: ${colors.base08};
        color: ${colors.base00};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
    	@keyframes blink {
        to {
            background-color: ${colors.base00};
            color: ${colors.base08};
        }
      }
    '';
  };
}