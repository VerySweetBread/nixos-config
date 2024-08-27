{ pkgs, config, ...}: {
  home.packages = [ pkgs.pulsemixer ];
  wayland.windowManager.hyprland.settings.windowrule = [
    "float, ^(pulsemixer)"
    "float, ^(nmtui)"
  ];

  xdg.configFile."waybar/scripts/wttr.py".source = pkgs.fetchurl {
    name = "waybar-wttr.py";
    url = "https://gist.githubusercontent.com/bjesus/f8db49e1434433f78e5200dc403d58a3/raw/47f9ffd573dc8e8edce0ea6708601b8e685a70ab/waybar-wttr.py";
    sha256 = "15j2cqg405q37wrrlm70mhp7rx6xnrn92rfm1ix6g3nl98ksh45g";
  };

  programs.waybar =
  let
    colors = config.lib.stylix.colors;
  in {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin = "9 13 -10 18";

        modules-left = ["hyprland/workspaces" "hyprland/language" "keyboard-state" "hyprland/submap"];
        modules-center = ["mpris"];
        modules-right = ["backlight" "network" "battery" "pulseaudio" "clock" "tray"];

        "hyprland/workspaces" = {
          disable-scroll = true;
        };

    "hyprland/language" = {
        format-en = "US";
        format-ru = "RU";
	      min-length = 5;
	      tooltip = false;
    };

    "keyboard-state" = {
        capslock = true;
        format = "{icon}";
        format-icons = {
            locked = "CUPS";
            unlocked = "";
        };
    };

    "clock" = {
        tooltip = false;
        format = "{:%a, %d %b %R}";
    };

    "custom/weather" = {
        format = "{}";
        tooltip = true;
        interval = 1800;
        exec = "python3 $HOME/.config/waybar/scripts/wttr.py";
        return-type = "json";
    };

    "pulseaudio" = {
        # scroll-step = 1; # %, can be a float
        reverse-scrolling = 1;
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
        };
        on-click = "alacritty --class pulsemixer -e pulsemixer";
        min-length = 13;
    };

    "custom/mem" = {
        format = "{} ";
        interval = 3;
        exec = "free -h | awk '/Mem:/{printf $3}'";
        tooltip = false;
    };

    "cpu" = {
      interval = 2;
      format = "{usage}% ";
      min-length = 6;
    };

    "temperature" = {
        # thermal-zone = 2;
        # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        critical-threshold = 80;
        # format-critical = "{temperatureC}°C {icon}";
        format = "{temperatureC}°C {icon}";
        format-icons = ["" "" "" "" ""];
        tooltip = false;
    };

    "network" = {
      format = "{ifname}";
      format-wifi = "{essid} ({signalStrength}%) ";
      format-ethernet = "{ifname} ";
      format-disconnected = "";
      tooltip-format = "{ifname}";
      tooltip-format-wifi = "{essid} ({signalStrength}%) ";
      tooltip-format-ethernet = "{ifname} ";
      tooltip-format-disconnected = "Disconnected";
      max-length = 50;
      on-click = "alacritty --class nmtui -e sh -c nmtui";
    };

    "backlight" = {
        device = "intel_backlight";
        format = "{percent}% {icon}";
        format-icons = [""];
        min-length = 7;
    };

    battery = {
        states = {
            warning = 30;
            critical = 15;
        };
        format = "{capacity}%";
        format-charging = "{capacity}% {time}";
        format-plugged = "{capacity}%";
        format-alt = "{time}";
        format-time = "{H}:{m}";
    };

    mpris = {
        format = "{title}";
        format-len = "20";
    };

    tray = {
        icon-size = 16;
        spacing = 0;
    };

      };
    };
  
    style = 
      ''
* {
    border: none;
    border-radius: 0;
    /* `otf-font-awesome` is required to be installed for icons */
    font-family: JetBrains Mono;
    font-weight: bold; 
    min-height: 20px;
}

window#waybar {
    background: transparent;
}

window#waybar.hidden {
    opacity: 0.2;
}

#workspaces {
    margin-right: 8px;
    border-radius: 10px;
    transition: none;
    background: #${colors.base00};
}

#workspaces button {
    transition: none;
    color: #${colors.base04};
    background: transparent;
    padding: 5px;
    font-size: 18px;
}

#workspaces button.persistent {
    font-size: 12px;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
#workspaces button:hover {
    transition: none;
    box-shadow: inherit;
    text-shadow: inherit;
    border-radius: inherit;
    color: #${colors.base05};
}

#workspaces button.active {
    background: #${colors.base02};
    color: #${colors.base05};
    border-radius: inherit;
}

#language {
    padding: 8px 0px 8px 8px;
    border-radius: 10px 0px 0px 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#keyboard-state {
    margin-right: 8px;
    padding: 8px 8px 8px 0px;
    border-radius: 0px 10px 10px 0px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#custom-pacman {
    padding-left: 16px;
    padding-right: 8px;
    border-radius: 10px 0px 0px 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#custom-mail {
    margin-right: 8px;
    padding-right: 16px;
    border-radius: 0px 10px 10px 0px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#submap {
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#clock {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#network {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#network.disconnected {
    color: #${colors.base00};
    background-color: #${colors.base08};
}

#custom-weather {
    padding-right: 16px;
    border-radius: 0px 10px 10px 0px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#pulseaudio {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#pulseaudio.muted {
    background-color: #${colors.base08};
    color: #${colors.base01};
}

#custom-mem {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#cpu {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#temperature {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#temperature.critical {
    background-color: #${colors.base08};
}

#backlight {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#battery {
    margin-right: 8px;
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#battery.charging {
    color: #${colors.base05};
    background-color: #${colors.base0B};
}

#battery.warning:not(.charging) {
    background-color: #${colors.base09};
    color: black;
}

#battery.critical:not(.charging) {
    background-color: #${colors.base08};
    color: #${colors.base05};
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#tray {
    padding-left: 16px;
    padding-right: 16px;
    border-radius: 10px;
    transition: none;
    color: #${colors.base05};
    background: #${colors.base00};
}

#mpris{
    background: #${colors.base00};
    border-radius: 10px;
    color: #${colors.base05};
    padding: 0px 8px;
    margin: 0px 8px;
}

#mpris.playing {
    background-color: #${colors.base0B};
    color: #${colors.base01};
}

#mpris.paused {
    background-color: #${colors.base0A};
    color: #${colors.base01};
}

@keyframes blink {
    to {
        background-color: #${colors.base05};
        color: #${colors.base00};
    }
}
      '';
  };
}
