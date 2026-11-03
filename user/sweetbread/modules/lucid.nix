{ config, lib, osConfig, pkgs, ... }:
let
  liveDecoder = if builtins.elem osConfig.networking.hostName [ "Rias" "Eclipse" ] then "cuda" else "vaapi";
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
  wallpapers = pkgs.fetchgit {
    url = "https://github.com/Sn3akyy1/lucid.git";
    rev = "bdd7f79da18efd837f79dcecbe5d2ec178abc10c";
    hash = "sha256-rXEYlr2bSe6EP6vxyayK7iXHk+Mmqs7duiE0pweIozI=";
    sparseCheckout = [ "/wallpapers/catppuccin-mocha/*" ];
    nonConeMode = true;
  };
  wallpaperDir = "${config.home.homeDirectory}/Wallpapers";
  wallpaperScript = "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper/set-wallpaper.sh";
  defaultWallpaper = "${wallpaperDir}/bluehour.jpg";
  hyprLua = import ../../../modules/user/hyprland/lua.nix { inherit lib; };
  colors = config.lib.stylix.colors.withHashtag;
  paletteFile = pkgs.runCommand "lucid-stylix-palette.json" {
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    python3 - "$out" ${lib.escapeShellArg config.stylix.base16Scheme} \
      ${lib.escapeShellArg "${source}/support/lucid"} \
      ${lib.escapeShellArg config.stylix.accent} <<'PY'
import json
import runpy
import sys
from pathlib import Path

output, scheme_path, scripts, accent_key = sys.argv[1:]
sys.path.insert(0, scripts)
from lucid_palette import at_tone
importer = runpy.run_path(str(Path(scripts) / "add-theme.py"))
scheme = importer["parse_base16"](scheme_path, Path(scheme_path).read_text())
if scheme is None:
    raise SystemExit("Stylix scheme is not valid Base16")
bg, fg, accents, hints = importer["to_palette"](scheme)
accent_key = accent_key.lower()
hints["primary"] = scheme["colors"][accent_key]
hints["secondary"] = scheme["colors"]["base0d" if accent_key != "base0d" else "base0e"]
hints["tertiary"] = scheme["colors"]["base0c" if accent_key == "base0b" else "base0b"]
palette = importer["build_palette"](
    bg, fg, accents, hints, mode="dark" if importer["is_dark"](bg) else "light"
)
if importer["is_dark"](bg):
    colors = scheme["colors"]
    # Keep the Base16 dark surface ladder. Lucid's built-in Mocha uses base00
    # for its main panels, with base01/base02 as the raised surfaces; the
    # generic Material builder starts at base02 and makes the whole shell pale.
    background_tone = importer["tone"](bg)
    darkest = importer["hx"](at_tone(bg, background_tone - 4))
    near_background = importer["hx"](at_tone(bg, background_tone - 2))
    palette.update({
        "surface": colors["base00"],
        "surface_dim": darkest,
        "surface_bright": importer["hx"](at_tone(bg, background_tone + 8)),
        "surface_container_lowest": darkest,
        "surface_container_low": near_background,
        "surface_container": colors["base00"],
        "surface_container_high": colors["base01"],
        "surface_container_highest": colors["base02"],
        "surface_variant": colors["base01"],
        "on_surface_variant": colors["base04"],
        "outline": colors["base03"],
        "outline_variant": colors["base01"],
    })
Path(output).write_text(json.dumps(palette, indent=2) + "\n")
PY
  '';
  themeMeta = pkgs.writeText "lucid-stylix-meta.json" (builtins.toJSON {
    id = "stylix";
    name = "Stylix";
    desc = "Active Stylix palette";
    swatchBg = colors.base00;
    swatchAccent = colors.${config.stylix.accent};
    source = "Home Manager";
    detected = "base16";
    user = true;
  });
  themeName = pkgs.writeText "lucid-current-theme" "stylix\n";
  applyTheme = pkgs.writeShellScript "lucid-apply-theme" ''
    exec "$HOME/.config/lucid/apply-theme-upstream.sh" --shell-only "$@"
  '';
  qmlPackages = with pkgs.qt6; [ qt5compat qtmultimedia ];
  tesseract = pkgs.tesseract4.override { enableLanguages = [ "eng" "rus" ]; };
  lucid = pkgs.writeShellScript "lucid" ''
    export NIXPKGS_QT6_QML_IMPORT_PATH="${lib.makeSearchPath "lib/qt-6/qml" qmlPackages}:''${NIXPKGS_QT6_QML_IMPORT_PATH:-}"
    export QT_PLUGIN_PATH="${lib.makeSearchPath "lib/qt-6/plugins" qmlPackages}:''${QT_PLUGIN_PATH:-}"
    export PATH="${lib.makeBinPath (with pkgs; [ bash cliphist coreutils curl ffmpeg grim imagemagick jq libnotify pulseaudio python3 wf-recorder wl-clipboard xdg-utils ])}:${tesseract}/bin:$PATH"
    exec ${pkgs.quickshell}/bin/qs --no-duplicate --path "${config.home.homeDirectory}/.config/quickshell"
  '';
  startWallpaper = pkgs.writeShellScript "lucid-wallpaper-start" ''
    export PATH="${lib.makeBinPath (with pkgs; [ awww bash coreutils ffmpeg imagemagick jq util-linux ])}:$PATH"
    selected="${defaultWallpaper}"
    if [ -s "${config.home.homeDirectory}/.cache/current_live_wallpaper" ]; then
      saved=$(${pkgs.coreutils}/bin/head -n1 "${config.home.homeDirectory}/.cache/current_live_wallpaper")
      if [ -f "$saved" ]; then
        selected="$saved"
      fi
    fi
    if [ -s "${config.home.homeDirectory}/.cache/current_wallpaper" ]; then
      saved=$(${pkgs.coreutils}/bin/cat "${config.home.homeDirectory}/.cache/current_wallpaper")
      if [ "$selected" = "${defaultWallpaper}" ] && [ -f "$saved" ]; then
        selected="$saved"
      fi
    fi
    exec "${wallpaperScript}" "$selected"
  '';
in {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;
  home.packages = with pkgs; [ cliphist ffmpeg grim imagemagick libnotify wf-recorder tesseract ];

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
    dock_qml="$target/luciddocks/Dock.qml"
    if grep -Fq '/var/lib/snapd/desktop/applications; do' "$dock_qml"; then
      $DRY_RUN_CMD sed -i \
        's#/var/lib/snapd/desktop/applications; do#/var/lib/snapd/desktop/applications $HOME/.nix-profile/share/applications $HOME/.local/state/nix/profile/share/applications /etc/profiles/per-user/$USER/share/applications /nix/profile/share/applications /nix/var/nix/profiles/default/share/applications /run/current-system/sw/share/applications; do#' \
        "$dock_qml"
    elif ! grep -Fq '/etc/profiles/per-user/$USER/share/applications; do' "$dock_qml"; then
      echo "Lucid launcher application scan pattern changed; refusing to skip Nix profiles" >&2
      exit 1
    fi
    keyboard_focus='WlrLayershell.keyboardFocus: dockWindow.menuOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None'
    keyboard_focus_fixed='WlrLayershell.keyboardFocus: dockWindow.menuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None'
    if grep -Fq "$keyboard_focus" "$dock_qml"; then
      $DRY_RUN_CMD sed -i \
        's/WlrLayershell.keyboardFocus: dockWindow.menuOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None/WlrLayershell.keyboardFocus: dockWindow.menuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None/' \
        "$dock_qml"
    elif ! grep -Fq "$keyboard_focus_fixed" "$dock_qml"; then
      echo "Lucid launcher keyboard focus pattern changed; refusing to skip focus fix" >&2
      exit 1
    fi
    if ! grep -Fq 'Nix focus workaround for Hyprland 0.57' "$dock_qml"; then
      if [ "$(grep -Fxc '    onMenuOpenChanged: {' "$dock_qml")" -ne 1 ]; then
        echo "Lucid menu-open handler changed; refusing to skip focus workaround" >&2
        exit 1
      fi
      $DRY_RUN_CMD sed -i '/    onMenuOpenChanged: {/a\
        // Nix focus workaround for Hyprland 0.57: detach pointer and keyboard focus while menus are open.\
        Quickshell.execDetached(["hyprctl", "eval", "hl.config({ input = { follow_mouse = " + (dockWindow.menuOpen ? 2 : 1) + " } })"]);' "$dock_qml"
    fi
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid-shell.qml} "$target/shell.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/LucidBar.qml} "$target/LucidBar.qml"
    $DRY_RUN_CMD mkdir -p "${wallpaperDir}" \
      "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper"
    $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -rltp --chmod=Du+rwx,Fu+rw --ignore-existing \
      "${wallpapers}/wallpapers/catppuccin-mocha/" "${wallpaperDir}/"
    $DRY_RUN_CMD install -m755 "${source}/support/wallpaper/set-wallpaper.sh" \
      "${wallpaperScript}"

    lucid_dir="${config.home.homeDirectory}/.config/lucid"
    $DRY_RUN_CMD mkdir -p "$lucid_dir/themes"
    $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -rltp --chmod=Du+rwx,Fu+rw --ignore-existing \
      "${source}/support/lucid/themes/" "$lucid_dir/themes/"
    for script in palette-edit.py lucid_palette.py add-theme.py scheme-gallery.py gen-light-palette.py; do
      $DRY_RUN_CMD install -m644 "${source}/support/lucid/$script" "$lucid_dir/$script"
    done
    $DRY_RUN_CMD install -m755 "${source}/support/lucid/apply-theme.sh" \
      "$lucid_dir/apply-theme-upstream.sh"
    $DRY_RUN_CMD install -m755 ${applyTheme} \
      "$lucid_dir/apply-theme.sh"

    if [ ! -e "$target/lucidprefs/prefs.json" ]; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid-prefs.json} "$target/lucidprefs/prefs.json"
    fi
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ -f "$target/lucidprefs/prefs.json" ]; then
      prefs_tmp=$(${pkgs.coreutils}/bin/mktemp "$target/lucidprefs/prefs.json.XXXXXX")
      if ${pkgs.jq}/bin/jq --arg font ${lib.escapeShellArg config.stylix.fonts.sansSerif.name} \
        --arg wallpaperDir ${lib.escapeShellArg wallpaperDir} \
        --arg decoder ${lib.escapeShellArg liveDecoder} \
        '.barEnabled = true | .widgetOnTop = false | .widgetHideFullscreen = true | .fontFamily = $font | .wallpaperFolder = $wallpaperDir | .liveDecoder = $decoder' \
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
    if [ ! -e "${config.home.homeDirectory}/.cache/current_theme" ]; then
      $DRY_RUN_CMD install -m644 ${themeName} \
        "${config.home.homeDirectory}/.cache/current_theme"
    fi
    if [ ! -e "${config.home.homeDirectory}/.cache/current_theme" ] || \
        [ "$(${pkgs.coreutils}/bin/cat "${config.home.homeDirectory}/.cache/current_theme")" = stylix ]; then
      $DRY_RUN_CMD install -m644 ${paletteFile} \
        "${config.home.homeDirectory}/.cache/quickshell/matugen.json"
    fi
  '';

  systemd.user.services.lucid = {
    Unit = {
      Description = "Lucid bar, dock and desktop widgets";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${startWallpaper}";
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
