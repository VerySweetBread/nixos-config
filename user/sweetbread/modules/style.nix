{ pkgs, config, lib, ... }: let
  kurumi-cursor = pkgs.stdenv.mkDerivation {
    name = "Kurumi cursor";

    # [Date A Live] Kurumi Tokisaki Cursor
    # Author: EbiEbiBeam
    # https://ko-fi.com/s/66a6c36df1
    src = pkgs.fetchzip {
      name = "KurumiCursor.zip";
      url = "https://ko-fi.com/api/file-upload/d2a5e046-1d48-49f9-9e41-9c230cc08821/download?transactionId=9dc3593e-b36b-40aa-910c-71ddee802d37";
      curlOpts = "-A HTTPie/3.2.4";
      extension = "zip";
      hash = "sha256-WYk8Hh92IE3CyUCAOp7QMKrYN8Hpt/cs+O17jhh5tJs=";
    };

    nativeBuildInputs = [ pkgs.win2xcur ];

    patchPhase = ''
      rm 02-Link.ani

      pwd
      echo $src
      mkdir Kurumi/cursors -p
      win2xcur $src/*.ani -o Kurumi/cursors

      cd Kurumi/
      echo "[Icon theme]"       >  index.theme
      echo "Name=Kurumi Cursor" >> index.theme

      cd cursors/
      mv '01-Normal' default
      ln -s default left_ptr
      ln -s default arrow
      mv '02-Link' pointer
      ln -s pointer hand2
      mv '03-Loading' wait
      ln -s wait progress
      mv '04-Help' help
      ln -s help question_arrow
      mv '05-Text Select' text
      ln -s text xterm
      mv '06-Handwriting' pencil
      mv '07-Precision' cross
      ln -s cross crosshair
      ln -s cross tcross
      mv '08-Unavailable' not-allowed
      # mv '09-Location Select' ?
      # mv '10-Person Select' ?
      mv '11-Vertical Resize' ns-resize
      ln -s ns-resize n-resize
      ln -s ns-resize s-resize
      ln -s ns-resize v_double_arrow
      ln -s ns-resize sb_v_double_arrow
      mv '12-Horizontal Resize' ew-resize
      ln -s ew-resize e-resize
      ln -s ew-resize w-resize
      ln -s ew-resize h_double_arrow
      ln -s ew-resize sb_h_double_arrow
      ln -s ew-resize left_side
      ln -s ew-resize right_side
      mv '13-Diagonal Resize 1' nw-resize
      ln -s nw-resize top_left_corner
      ln -s nw-resize bottom_right_corner
      mv '14-Diagonal Resize 2' ne-resize
      ln -s ne-resize top_right_corner
      ln -s ne-resize bottom_left_corner
      mv '15-Move' move
      ln -s move nesw-resize
      ln -s move grab
      ln -s move grabbing
      ln -s move fleur
      # mv '16-Alternate Select' ?

      cd ../..
    '';

    installPhase = ''
      mkdir $out/share/icons -p
      cp Kurumi $out/share/icons -r
    '';
  };
in {
# {
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
      name = "Kurumi";
      size = 32;
      package = kurumi-cursor;
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
