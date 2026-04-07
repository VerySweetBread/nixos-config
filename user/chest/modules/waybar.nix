{ config, pkgs, ... }: {
  programs.waybar.settings.mainBar.spacing = 4;
  programs.waybar.style = let
    colors = config.lib.stylix.colors.withHashtag;
    accent = colors.base0E;
    scssFile = pkgs.writeText "waybar.scss" /*scss*/ ''
      window#waybar {
        background: transparent;
        color: ${colors.base05};
        font-weight: bold;
        font-size: .85em;
        & > * {padding: 0 0 6px 0;}
      }
      .modules-center{
        background: ${colors.base01}CC;
        border-radius: 12px;
        padding: 10px;
        box-shadow: 5px 5px 10px rgba(0, 0, 0, 0.4);
      }

      #left,
      #right,
      #center       {
        background: ${colors.base02};
        padding: 0 2px;
        margin: 0 8px;
        border-radius: 8px;
      }
      #left{
        margin-left: 0;}

      #right{
        margin-right: 0;}

      #clock{
        padding-right: 10px;}

      #cava {
        padding: 0 10px;}

      #language { padding: 8px; }

      /*#workspaces,
      #tray {
        background: ${colors.base01};
      }*/

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
}