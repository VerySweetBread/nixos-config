{ config, pkgs, ... }:
  let
    colors = config.lib.stylix.colors;
  in {
    home.packages = [ pkgs.mako ];
    xdg.configFile."mako/config".text = ''
      background-color=#${colors.base00}
      text-color=#${colors.base05}
      border-color=#${colors.base0B}
      border-radius=10
      margin=16
      progress-color=over #${colors.base0A}
      default-timeout=5000

      [urgency=high]
      border-color=#${colors.base09}
      
      [urgency=low]
      border-color=#${colors.base04}
    '';
  }
