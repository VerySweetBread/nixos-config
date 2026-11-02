{ config, lib, pkgs, ... }:
let
  source = pkgs.fetchgit {
    url = "https://github.com/Sn3akyy1/lucid.git";
    rev = "bdd7f79da18efd837f79dcecbe5d2ec178abc10c";
    hash = "sha256-b6qylKjCGYy2Yo64i1w9g4oGrYgcXf502jY9qNNWhSI=";
    sparseCheckout = [
      "/*"
      "!/wallpapers/*"
      "!/assets/*.webp"
    ];
    nonConeMode = true;
  };
  hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };
  colors = config.lib.stylix.colors.withHashtag;
  accent = colors.${config.stylix.accent};
  palette = {
    primary = accent;
    on_primary = colors.base00;
    primary_container = accent;
    on_primary_container = colors.base05;
    secondary = colors.base0D;
    secondary_container = colors.base02;
    tertiary = colors.base0E;
    on_tertiary = colors.base00;
    error = colors.base08;
    on_error = colors.base00;
    error_container = colors.base03;
    surface = colors.base00;
    on_surface = colors.base05;
    surface_variant = colors.base02;
    on_surface_variant = colors.base07;
    surface_dim = colors.base01;
    surface_container_lowest = colors.base01;
    surface_container_low = colors.base00;
    surface_container = colors.base00;
    surface_container_high = colors.base02;
    surface_container_highest = colors.base03;
    outline = colors.base04;
    outline_variant = colors.base02;
    inverse_surface = colors.base05;
    shadow = "#000000";
    scrim = "#000000";
    source_color = accent;
  };
  paletteFile = pkgs.writeText "lucid-stylix-palette.json" (builtins.toJSON palette);
  themeMeta = pkgs.writeText "lucid-stylix-meta.json" (builtins.toJSON {
    id = "stylix";
    name = "Stylix";
    desc = "Active Stylix palette";
    swatchBg = colors.base00;
    swatchAccent = accent;
    source = "Home Manager";
    detected = "base16";
    user = true;
  });
  themeName = pkgs.writeText "lucid-current-theme" "stylix\n";
  qmlPackages = with pkgs.qt6; [ qt5compat qtmultimedia ];
  lucid = pkgs.writeShellScript "lucid" ''
    export NIXPKGS_QT6_QML_IMPORT_PATH="${lib.makeSearchPath "lib/qt-6/qml" qmlPackages}:''${NIXPKGS_QT6_QML_IMPORT_PATH:-}"
    export QT_PLUGIN_PATH="${lib.makeSearchPath "lib/qt-6/plugins" qmlPackages}:''${QT_PLUGIN_PATH:-}"
    export PATH="${lib.makeBinPath (with pkgs; [ bash coreutils curl jq pulseaudio python3 xdg-utils ])}:$PATH"
    exec ${pkgs.quickshell}/bin/qs --no-duplicate --path "${config.home.homeDirectory}/.config/quickshell"
  '';
in {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;

  home.activation.installLucid = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.home.homeDirectory}/.config/quickshell"
    $DRY_RUN_CMD mkdir -p "$target"
    $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -rltp --chmod=Du+rwx,Fu+rw \
      --exclude='/shell.qml' \
      --exclude='/LucidBar.qml' \
      --exclude='/lucidprefs/prefs.json' \
      --exclude='/lucidbar/blur.json' \
      --exclude='/lucidbar/clock_reminders.json' \
      --exclude='/lucidbar/mpris_shazam.json' \
      --exclude='/luciddocks/pinned.json' \
      --exclude='/luciddocks/usage.json' \
      --exclude='/luciddocks/wallpaper.json' \
      --exclude='/lucidmoji/config.json' \
      --exclude='/lucidmoji/state.json' \
      --exclude='/lucidkeys/state.json' \
      --exclude='/lucidwidgets/widgets.json' \
      "${source}/" "$target/"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid-shell.qml} "$target/shell.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/LucidBar.qml} "$target/LucidBar.qml"

    if [ ! -e "$target/lucidprefs/prefs.json" ]; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid-prefs.json} "$target/lucidprefs/prefs.json"
    fi
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ -f "$target/lucidprefs/prefs.json" ]; then
      prefs_tmp=$(${pkgs.coreutils}/bin/mktemp "$target/lucidprefs/prefs.json.XXXXXX")
      if ${pkgs.jq}/bin/jq --arg font '${config.stylix.fonts.sansSerif.name}' \
        '.barEnabled = true | .widgetOnTop = false | .widgetHideFullscreen = true | .fontFamily = $font' \
        "$target/lucidprefs/prefs.json" > "$prefs_tmp"; then
        ${pkgs.coreutils}/bin/chmod 644 "$prefs_tmp"
        ${pkgs.coreutils}/bin/mv "$prefs_tmp" "$target/lucidprefs/prefs.json"
      else
        ${pkgs.coreutils}/bin/rm -f "$prefs_tmp"
        exit 1
      fi
    fi
    if [ ! -e "$target/luciddocks/pinned.json" ]; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid-pinned.json} "$target/luciddocks/pinned.json"
    fi
    if [ ! -e "$target/lucidwidgets/widgets.json" ]; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid-widgets.json} "$target/lucidwidgets/widgets.json"
    fi

    for pair in \
      'blur.json lucidbar/blur.json' \
      'clock_reminders.json lucidbar/clock_reminders.json' \
      'mpris_shazam.json lucidbar/mpris_shazam.json' \
      'usage.json luciddocks/usage.json' \
      'wallpaper.json luciddocks/wallpaper.json' \
      'moji-config.json lucidmoji/config.json' \
      'moji-state.json lucidmoji/state.json' \
      'keys-state.json lucidkeys/state.json'; do
      set -- $pair
      if [ ! -e "$target/$2" ]; then
        $DRY_RUN_CMD install -m644 "${source}/defaults/$1" "$target/$2"
      fi
    done

    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/lucid/themes/stylix" \
      "${config.home.homeDirectory}/.cache/quickshell"
    $DRY_RUN_CMD install -m644 ${paletteFile} \
      "${config.home.homeDirectory}/.config/lucid/themes/stylix/quickshell.json"
    $DRY_RUN_CMD install -m644 ${themeMeta} \
      "${config.home.homeDirectory}/.config/lucid/themes/stylix/meta.json"
    $DRY_RUN_CMD install -m644 ${paletteFile} \
      "${config.home.homeDirectory}/.cache/quickshell/matugen.json"
    $DRY_RUN_CMD install -m644 ${themeName} \
      "${config.home.homeDirectory}/.cache/current_theme"
  '';

  systemd.user.services.lucid = {
    Unit = {
      Description = "Lucid bar, dock and desktop widgets";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lucid}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  wayland.windowManager.hyprland.settings = {
    on = [ (hyprLua.onStart [ "systemctl --user start lucid.service" ]) ];
    bind = [
      (hyprLua.bind "SUPER + SHIFT + G" (hyprLua.exec "qs ipc call widgets panel"))
    ];
  };
}
