{ pkgs, config, lib, osConfig, inputs, ... }: let
  mikuFrost = builtins.elem osConfig.networking.hostName [ "Eclipse" "Impreza" ];
  colors = config.lib.stylix.colors.withHashtag;
  accent = colors.${config.stylix.accent};
  # Render the same Stylix templates, changing only native translucency and accent.
  kvantumConfig = config.lib.stylix.colors {
    template = builtins.readFile "${inputs.stylix}/modules/qt/kvconfig.mustache";
    extension = ".kvconfig";
  };
  kvantumSvg = config.lib.stylix.colors {
    template = builtins.readFile "${inputs.stylix}/modules/qt/kvantum.svg.mustache";
    extension = ".svg";
  };
  frostKvantum = pkgs.runCommandLocal "miku-frost-kvantum" {} ''
    directory="$out/share/Kvantum/Base16Kvantum"
    mkdir -p "$directory"
    cp ${kvantumConfig} "$directory/Base16Kvantum.kvconfig"
    cp ${kvantumSvg} "$directory/Base16Kvantum.svg"
    substituteInPlace "$directory/Base16Kvantum.kvconfig" \
      --replace-fail 'translucent_windows=false' 'translucent_windows=true' \
      --replace-fail 'blurring=false' 'blurring=true' \
      --replace-fail 'reduce_window_opacity=10' 'reduce_window_opacity=18' \
      --replace-fail 'highlight.color=${colors.base0E}' 'highlight.color=${accent}'
    substituteInPlace "$directory/Base16Kvantum.svg" \
      --replace-fail '${colors.base0D}' '${accent}'
  '';
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
      hash = "sha256-aWnq1SckuRBVmX1T+htbideBbYUGvAqDyRB1v3cbpyA=";
    };

    nativeBuildInputs = [ pkgs.win2xcur ];

    patchPhase = ''
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
    overlays.enable = false;

    targets = {
      hyprland.enable = false;
      waybar.enable = false;
      kitty.variant256Colors = true;
      gtk.extraCss = lib.mkIf mikuFrost ''
        /* Native background alpha keeps text and controls fully opaque. */
        @define-color accent_color ${accent};
        @define-color accent_bg_color ${accent};
        @define-color theme_selected_bg_color ${accent};
        @define-color window_bg_color alpha(${colors.base01}, 0.78);
        @define-color view_bg_color alpha(${colors.base00}, 0.48);
        @define-color headerbar_bg_color alpha(${colors.base01}, 0.76);
        @define-color headerbar_backdrop_color @window_bg_color;
        @define-color sidebar_bg_color alpha(${colors.base01}, 0.72);
        @define-color sidebar_backdrop_color @window_bg_color;
        @define-color dialog_bg_color alpha(${colors.base01}, 0.84);
        @define-color popover_bg_color alpha(${colors.base01}, 0.90);
        @define-color theme_bg_color @window_bg_color;
        @define-color theme_base_color @view_bg_color;
      '';
    };

    # Keep a file-backed scheme for consumers such as Neofetch.
    base16Scheme = if mikuFrost then toString (pkgs.writeText "miku-frost.yaml" ''
      scheme: "Miku Frost"
      author: "chest"
      base00: "101724"
      base01: "192534"
      base02: "253247"
      base03: "47586B"
      base04: "93A8BA"
      base05: "E1EFF2"
      base06: "F1F8F8"
      base07: "F9FFFF"
      base08: "EF829A"
      base09: "F5AB82"
      base0A: "EED69A"
      base0B: "69DCC7"
      base0C: "43D6CD"
      base0D: "7BB9E8"
      base0E: "B29DF4"
      base0F: "E3A8D8"
    '') else "${pkgs.base16-schemes}/share/themes/eris.yaml";
    accent = if mikuFrost then "base0C" else "base0E";
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/kx/wallhaven-kxedr7.jpg";
      sha256 = "0ypqnq7bsr2giq7nq1c3xrw2m0gkii9j5zhfp512r93wc96zvm50";
    };

    icons = {
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

  qt.kvantum.themes = lib.mkIf mikuFrost (lib.mkForce [ frostKvantum ]);

  # Notifications share the island's surface and rounded, borderless silhouette.
  services.mako.settings = lib.mkIf mikuFrost {
    background-color = lib.mkForce "${colors.base01}D9";
    text-color = lib.mkForce colors.base05;
    border-size = lib.mkForce 0;
    border-radius = 22;
    padding = "12";
    progress-color = lib.mkForce "over ${accent}33";
    "urgency=low".background-color = lib.mkForce "${colors.base01}D9";
    "urgency=critical" = {
      background-color = lib.mkForce "${colors.base01}F0";
      text-color = lib.mkForce colors.base08;
    };
  };

  # Yazi uses its own true-colour theme rather than the terminal ANSI palette.
  programs.yazi.theme = lib.mkIf mikuFrost {
    filetype.rules = lib.mkBefore [
      { url = "*/"; fg = colors.base05; bold = false; }
    ];
    icon.conds = lib.mkBefore [
      { "if" = "dir"; text = ""; fg = accent; }
    ];
    mgr.border_style.fg = lib.mkForce colors.base03;
    indicator = {
      current = { fg = colors.base05; bg = lib.mkForce colors.base02; };
      preview = { fg = colors.base05; bg = lib.mkForce colors.base02; };
    };
    tabs = {
      active = { fg = lib.mkForce colors.base00; bg = lib.mkForce accent; };
      inactive = { fg = lib.mkForce colors.base04; bg = lib.mkForce colors.base01; };
    };
    mode = {
      normal_main = { fg = lib.mkForce colors.base00; bg = lib.mkForce accent; };
      normal_alt = { fg = lib.mkForce accent; bg = lib.mkForce colors.base01; };
    };
    input = {
      border.fg = lib.mkForce accent;
      selected.bg = lib.mkForce colors.base02;
    };
    pick.border.fg = lib.mkForce accent;
    completion.border.fg = lib.mkForce accent;
    tasks.border.fg = lib.mkForce accent;
  };

  # Keep the original terminal glass, with colours inherited from Stylix.
  programs.ghostty.themes.stylix = lib.mkIf mikuFrost {
    background = lib.mkForce config.lib.stylix.colors.base00;
    cursor-color = lib.mkForce config.lib.stylix.colors.base0C;
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
