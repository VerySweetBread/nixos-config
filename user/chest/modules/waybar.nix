{ config, pkgs, ... }: {
  programs.waybar.settings.mainBar.spacing = 4;
  programs.waybar.style = let
    colors = config.lib.stylix.colors.withHashtag;
    accent = colors.base0E;
    scssFile = pkgs.writeText "waybar.scss" /*scss*/ ''
      window#waybar {
        background: ${colors.base00}80;
        color: ${colors.base05};
        font-weight: bold;
        font-size: .85em;
      }

      #mpris,
      #pulseaudio,
      #network,
      #battery,
      #cpu,
      #temperature,
      #custom-mem,
      #clock {
        background: ${colors.base01};
        padding: 8px;
      }

      #language { padding: 8px; }

      #workspaces,
      #tray {
        background: ${colors.base01};
      }

      #workspaces button {
        color: ${colors.base05};
        padding: 0 2px;
        border-radius: 999px;
        border: 1pt solid transparent;
        min-width: 20px;

        &:hover { background: ${colors.base02}; }

        &.active {
          background: ${accent};
          color: ${colors.base00};
          min-width: 30px;

          &:hover {
            border-color: ${accent};
            background: ${colors.base02};
            color: ${accent};
          }
        }
      }

      #mpris {
        border-radius: 0 0 20px 20px;
        padding: 10px;
        &:hover { background: ${colors.base02}; }
        &.playing {
          border: 3px solid ${accent};
          border-top-color: transparent;
          padding: calc(10px - 3px);
        }
      }

      #tray {
        widget {
          border: 1pt solid transparent;
          &:hover { background: ${colors.base02}; }
          & > image { padding: 8px; }
        }

        & > .passive { border-color: ${colors.base02}; }
        & > .needs-attention { border-color: ${colors.base09}; }
      }

      #pulseaudio {
        &:hover { background: ${colors.base02}; }
        &.muted {
          background: ${colors.base08};
          color: ${colors.base00};

          &:hover {
            color: ${colors.base08};
            background: ${colors.base02};
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
}