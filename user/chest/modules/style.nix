{ pkgs, config, lib, ... }: {
  stylix = {
    enable = true;
    targets = {
      hyprland.enable = false;
      waybar.enable = false;
      kitty.variant256Colors = true;
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/eris.yaml";
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/kx/wallhaven-kxedr7.jpg";
      sha256 = "0ypqnq7bsr2giq7nq1c3xrw2m0gkii9j5zhfp512r93wc96zvm50";
    };

    iconTheme = {
      enable = true;
      package = pkgs.pop-icon-theme;
      dark = "Pop-Dark";
    };

    fonts = {
      monospace = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
      };

      sizes = {
        applications = 13;
        desktop = 12;
      };
    };

    opacity = {
      popups = .8;
      terminal = .5;
    };
  };
}
