{ osConfig, config, pkgs, ... }: {
  home.packages = with pkgs; [
    font-awesome
    nerd-fonts.symbols-only
    playerctl
  ];
  
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
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
  };
}