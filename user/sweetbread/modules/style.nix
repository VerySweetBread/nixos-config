{ pkgs, config, lib, ... }: {
  stylix = {
    enable = true;
    targets = {
      hyprpaper.enable = lib.mkForce false;
      waybar.enable = false;
      kitty.variant256Colors = true;
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/8o/wallhaven-8o52j2.jpg";
      sha256 = "sha256-u4d21a0Kh5OHEzQMSQ7+ey/Va2ftS1DefrOQFahaeC4=";
    };

    iconTheme = {
      enable = true;
      package = pkgs.pop-icon-theme;
      dark = "Pop-Dark";
    };

    cursor = {
      name = "catppuccin-mocha-green-cursors";
      size = 24;
      package = pkgs.catppuccin-cursors.mochaGreen;
    };

    fonts = {
      monospace = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
      };

      serif = {
        name = "GabrieLa";
        package = (pkgs.google-fonts.override { fonts = [ "Gabriela" ]; });
      };

      emoji = {
        package = pkgs.noto-fonts-monochrome-emoji;
        name = "Noto Emoji";
      };

      sizes = {
        applications = 13;
        desktop = 12;
      };
    };

    opacity = {
      popups = .8;
      terminal = .9;
    };
  };
}
