{ config, pkgs, ... }: {
  programs.waybar.settings.mainBar.spacing = 8;
  programs.waybar.style = let
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

  wayland.windowManager.hyprland.settings.layerrule = [
    "blur on, match:namespace waybar"
  ];
}