{ lib, pkgs, ... }: {
  home.packages = [ pkgs.alacritty ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = lib.mkDefault 0.5;
        blur = true;
      };

      font = lib.mkDefault {
        size = 13.0;
        normal = {
          family = "JetBrains Mono";
          style = "Bold";
        };
      };

      colors.primary.background = lib.mkDefault "#1d2021";
    };
  };
}
