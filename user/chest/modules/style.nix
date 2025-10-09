{ pkgs, config, lib, ... }: let
  miku-cursor = pkgs.stdenv.mkDerivation {
    name = "Miku cursor";

    # Hatsune Miku Cursor
    # Author: NOiiRE ❖
    # https://ko-fi.com/s/dcea0e990f
    src = pkgs.fetchzip {
      name = "MikuCursor.zip";
      url = "https://ko-fi.com/api/file-upload/cf0bb0a7-feb8-4090-8e2e-68fd33b7b040/download?transactionId=684d8995-2014-4f9f-bb77-39e4dae3bad7";
      curlOpts = "-A HTTPie/3.2.4";
      extension = "zip";
      hash = "sha256-WYk8Hh92IE3CyUCAOp7QMKrYN8Hpt/cs+O17jhh5tJs=";
    };

    nativeBuildInputs = [ pkgs.win2xcur ];

    patchPhase = ''
      rm 02-Link.ani

      pwd
      echo $src
      mkdir Miku/cursors -p
      win2xcur $src/*.ani -o Miku/cursors

      cd Miku/
      echo "[Icon theme]"     >  index.theme
      echo "Name=Miku Cursor" >> index.theme

      cd cursors/
      mv 'Miku normal' default
      ln -s default left_ptr
      ln -s default arrow
      mv 'Miku link' pointer
      ln -s pointer hand2
      mv 'Miku busy' wait
      ln -s wait progress
      mv 'Miku help' help
      ln -s help question_arrow
      mv 'Miku text' text
      ln -s text xterm
      mv 'Miku hand' pencil
      mv 'Miku precision' cross
      ln -s cross crosshair
      ln -s cross tcross
      mv 'Miku unavailable' not-allowed
      # mv 'Miku location' ?
      # mv 'Miku person' ?
      mv 'Miku vert' ns-resize
      ln -s ns-resize n-resize
      ln -s ns-resize s-resize
      ln -s ns-resize v_double_arrow
      ln -s ns-resize sb_v_double_arrow
      mv 'Miku horz' ew-resize
      ln -s ew-resize e-resize
      ln -s ew-resize w-resize
      ln -s ew-resize h_double_arrow
      ln -s ew-resize sb_h_double_arrow
      ln -s ew-resize left_side
      ln -s ew-resize right_side
      mv 'Miku dgn1' nw-resize
      ln -s nw-resize top_left_corner
      ln -s nw-resize bottom_right_corner
      mv 'Miku dgn2' ne-resize
      ln -s ne-resize top_right_corner
      ln -s ne-resize bottom_left_corner
      mv 'Miku move' move
      ln -s move nesw-resize
      ln -s move grab
      ln -s move grabbing
      ln -s move fleur
      # mv 'Miku alt' ?

      cd ../..
    '';

    installPhase = ''
      mkdir $out/share/icons -p
      cp Miku $out/share/icons -r
    '';
  };
in {
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

    cursor = {
      name = "Miku";
      size = 16;
      package = miku-cursor;
    };

    fonts = {
      monospace = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
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
      terminal = .5;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  gtk = {
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
