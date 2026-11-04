{ config, lib, osConfig, pkgs, ... }:
let
  host = osConfig.networking.hostName;
  isRias = host == "Rias";
  liveDecoder = if builtins.elem osConfig.networking.hostName [ "Rias" "Eclipse" ] then "cuda" else "vaapi";
  source = pkgs.applyPatches {
    src = pkgs.fetchgit {
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
    patches = [ (pkgs.writeText "lucid-scratchpad-target.patch" ''
      diff --git a/support/hypr/modules/specials.lua b/support/hypr/modules/specials.lua
      --- a/support/hypr/modules/specials.lua
      +++ b/support/hypr/modules/specials.lua
      @@ -176,8 +176,11 @@
       function M.scratchpad()
           return function()
               if space(config(), "special").enabled == false then return end
      -        local shown = hl.get_active_special_workspace()
      -        local name = shown and (shown.name:gsub("^special:", "")) or "special"
      -        hl.dispatch(hl.dsp.workspace.toggle_special(name))
      +        local shown = hl.get_active_special_workspace()
      +        if shown and shown.name == "special:special" then
      +            hl.dispatch(hl.dsp.workspace.toggle_special("special"))
      +        else
      +            hl.dispatch(hl.dsp.focus({ workspace = "special:special" }))
      +        end
           end
       end
    '') ];
  };
  wallpaperDir = "${config.home.homeDirectory}/Wallpapers";
  wallpaperScript = "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper/set-wallpaper.sh";
  widgetLayout = if osConfig.networking.hostName == "Rias"
    then ../../../modules/user/lucid/lucid-widgets-rias.json
    else ../../../modules/user/lucid/lucid-widgets.json;
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
  themeAutoPatch = pkgs.writeText "lucid-theme-auto.patch" ''
    --- a/Prefs.qml
    +++ b/Prefs.qml
    @@ -455,5 +455,12 @@
         function setColorMode(mode) {
    +        if (mode === "auto") {
    +            root.setAutoColorMode(true);
    +            return;
    +        }
    -        if ((mode !== "dark" && mode !== "light") || mode === root.colorMode)
    +        if (mode !== "dark" && mode !== "light")
                 return;
     
    +        root.setAutoColorMode(false);
    +        if (mode === root.colorMode)
    +            return;
             // set straight away so the control answers the click; the cache file is
    @@ -484,2 +491,4 @@
         function setAutoColorMode(on) {
    +        if (on && root.currentTheme !== "matugen" && root.currentTheme !== "pywal")
    +            return;
             root.autoColorMode = on;
    @@ -1669,1 +1678,5 @@
    -        onLoaded: root.currentTheme = text().trim() || "matugen"
    +        onLoaded: {
    +            root.currentTheme = text().trim() || "matugen";
    +            if (root.currentTheme !== "matugen" && root.currentTheme !== "pywal" && root.autoColorMode)
    +                root.setAutoColorMode(false);
    +        }
    --- a/lucidprefs/ThemePage.qml
    +++ b/lucidprefs/ThemePage.qml
    @@ -11,9 +11,14 @@
         readonly property string home: Quickshell.env("HOME")
         readonly property string currentTheme: Prefs.currentTheme
    -    readonly property var modeOptions: [{
    +    readonly property bool wallpaperDerivedTheme: page.currentTheme === "matugen" || page.currentTheme === "pywal"
    +    readonly property var modeOptions: [{
             "key": "dark",
             "label": "Dark"
         }, {
             "key": "light",
             "label": "Light"
         }]
    +    readonly property var autoModeOptions: page.modeOptions.concat([{
    +        "key": "auto",
    +        "label": "Auto"
    +    }])
    @@ -22,1 +27,1 @@
    -    readonly property string modeHint: page.currentTheme === "matugen" || page.currentTheme === "pywal" ? "Re-derives the palette from your wallpaper in the mode you pick. Applications are asked to match." : (page.currentTheme === "colour" ? "Builds the palette from your colour again in the mode you pick. Applications are asked to match." : "Builds a light palette from this theme's own colours. Applications are asked to match.")
    +    readonly property string modeHint: page.wallpaperDerivedTheme ? "Auto follows the wallpaper brightness whenever you change the wallpaper. Dark and Light stay fixed until you choose another mode." : (page.currentTheme === "colour" ? "Builds the palette from your colour again in the mode you pick. Applications are asked to match." : "Builds a light palette from this theme's own colours. Applications are asked to match.")
    @@ -273,6 +278,6 @@
                 M3Segmented {
    -                width: Theme.dp(200)
    -                current: Prefs.colorMode
    -                options: page.modeOptions
    +                width: Theme.dp(page.wallpaperDerivedTheme ? 300 : 200)
    +                current: Prefs.autoColorMode && page.wallpaperDerivedTheme ? "auto" : Prefs.colorMode
    +                options: page.wallpaperDerivedTheme ? page.autoModeOptions : page.modeOptions
                     onChosen: (key) => {
                         return Prefs.setColorMode(key);
    @@ -284,13 +289,0 @@
    -        SettingRow {
    -            title: "Follow the wallpaper"
    -            description: "Picks light for a bright wallpaper and dark for a dark one, every time the wallpaper changes. A hand-picked mode holds until the wallpaper changes next."
    -
    -            M3Switch {
    -                checked: Prefs.autoColorMode
    -                onToggled: (v) => {
    -                    return Prefs.setAutoColorMode(v);
    -                }
    -            }
    -
    -        }
    -
  '';
  settingsScreenPatch = pkgs.writeText "lucid-settings-screen.patch" ''
    --- a/lucidprefs/Settings.qml
    +++ b/lucidprefs/Settings.qml
    @@ -9,2 +9,4 @@
     FloatingWindow {
         id: win
    +    property var preferredScreen: null
    +    screen: win.preferredScreen || Monitors.mainScreen
  '';
  wallpaperAutoPatch = pkgs.writeText "lucid-wallpaper-auto.patch" ''
    --- a/set-wallpaper.sh
    +++ b/set-wallpaper.sh
    @@ -32,4 +32,5 @@
     MODE="''${2:-}"
     if [[ -z "$MODE" ]]; then
    -    if grep -qE '"autoColorMode"[[:space:]]*:[[:space:]]*true' "$HOME/.config/quickshell/lucidprefs/prefs.json" 2>/dev/null; then
    +    if [[ "$CURRENT_THEME" == matugen || "$CURRENT_THEME" == pywal ]] && \
    +        grep -qE '"autoColorMode"[[:space:]]*:[[:space:]]*true' "$HOME/.config/quickshell/lucidprefs/prefs.json" 2>/dev/null; then
             MODE=auto
  '';
  kdeConnectBridgePython = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
  applyTheme = pkgs.writeShellScript "lucid-apply-theme" ''
    case "''${1:-}" in
      --apps-only) exit 0 ;;
      --shell-only) shift ;;
    esac
    exec "$HOME/.config/lucid/apply-theme-upstream.sh" --shell-only "$@"
  '';
  qmlPackages = with pkgs.qt6; [ qt5compat qtmultimedia ];
  tesseract = pkgs.tesseract4.override { enableLanguages = [ "eng" "rus" ]; };
  lucid = pkgs.writeShellScript "lucid" ''
    export NIXPKGS_QT6_QML_IMPORT_PATH="${lib.makeSearchPath "lib/qt-6/qml" qmlPackages}:''${NIXPKGS_QT6_QML_IMPORT_PATH:-}"
    export QT_PLUGIN_PATH="${lib.makeSearchPath "lib/qt-6/plugins" qmlPackages}:''${QT_PLUGIN_PATH:-}"
    export PATH="${lib.makeBinPath (with pkgs; [ bash cliphist coreutils curl ffmpeg grim imagemagick jq libnotify pulseaudio kdeConnectBridgePython pywal16 wf-recorder wl-clipboard xdg-utils ])}:${tesseract}/bin:$PATH"
    exec ${pkgs.quickshell}/bin/qs --no-duplicate --path "${config.home.homeDirectory}/.config/quickshell"
  '';
  startWallpaper = pkgs.writeShellScript "lucid-wallpaper-start" ''
    export PATH="${lib.makeBinPath (with pkgs; [ awww bash coreutils ffmpeg imagemagick jq python3 pywal16 util-linux ])}:$PATH"
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
    if [ ! -f "$selected" ]; then
      echo "Lucid startup wallpaper not found; leaving the current wallpaper unchanged" >&2
      exit 0
    fi
    exec "${wallpaperScript}" "$selected"
  '';
in {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;
  home.packages = with pkgs; [ cliphist ffmpeg grim imagemagick libnotify pywal16 wf-recorder tesseract ];

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
    $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch -p1 -d "$target" < ${../../../modules/user/lucid/idle-work.patch}
    if ! grep -Fq 'mode === "auto"' "$target/Prefs.qml"; then
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch --forward -p1 -d "$target" < ${themeAutoPatch}
    fi
    if ! grep -Fq 'property var preferredScreen: null' "$target/lucidprefs/Settings.qml"; then
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch --forward -p1 -d "$target" < ${settingsScreenPatch}
    fi
    settings_qml="$target/lucidprefs/Settings.qml"
    if ! grep -Fq 'win.preferredScreen = Monitors.focusedScreen || Monitors.mainScreen;' "$settings_qml"; then
      $DRY_RUN_CMD sed -i '/if (win.visible) {/a\            win.preferredScreen = Monitors.focusedScreen || Monitors.mainScreen;' "$settings_qml"
    fi
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
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/lucid-shell.qml} "$target/shell.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/LucidBar.qml} "$target/LucidBar.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/Agenda.qml} "$target/Agenda.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/CalendarSource.qml} "$target/CalendarSource.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/ClockCalendar.qml} "$target/lucidbar/ClockCalendar.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/thunderbird-calendar.py} "$target/thunderbird-calendar.py"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/WidgetLayer.qml} "$target/lucidwidgets/WidgetLayer.qml"
    $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/WidgetsPage.qml} "$target/lucidprefs/WidgetsPage.qml"
    $DRY_RUN_CMD mkdir -p "${wallpaperDir}" \
      "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper"
    $DRY_RUN_CMD install -m755 "${source}/support/wallpaper/set-wallpaper.sh" \
      "${wallpaperScript}"
    if ! grep -Fq 'CURRENT_THEME" == matugen' "${wallpaperScript}"; then
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch --forward -p1 -d "$(dirname ${lib.escapeShellArg wallpaperScript})" < ${wallpaperAutoPatch}
    fi

    lucid_dir="${config.home.homeDirectory}/.config/lucid"
    $DRY_RUN_CMD mkdir -p "$lucid_dir/themes"
    if [ "${host}" = Rias ] && [ ! -s "$lucid_dir/keybinds.json" ]; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/lucid-keybinds-rias.json} "$lucid_dir/keybinds.json"
    fi
    monitor_file="${config.home.homeDirectory}/.config/hypr/lucid-monitors.lua"
    if [ "${host}" = Rias ] && { [ ! -s "$monitor_file" ] || ! grep -qE 'output[[:space:]]*=' "$monitor_file"; } && \
       ! grep -qE 'workspace[[:space:]]*=' "$monitor_file" 2>/dev/null; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/lucid-monitors-rias.lua} "$monitor_file"
    fi
    $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -rltp --chmod=Du+rwx,Fu+rw --ignore-existing \
      "${source}/support/lucid/themes/" "$lucid_dir/themes/"
    for script in palette-edit.py lucid_palette.py add-theme.py scheme-gallery.py gen-light-palette.py; do
      $DRY_RUN_CMD install -m644 "${source}/support/lucid/$script" "$lucid_dir/$script"
    done
    for script in gen-pywal-palette.py set-mode.sh wallpaper-mode.sh; do
      $DRY_RUN_CMD install -m755 "${source}/support/lucid/$script" "$lucid_dir/$script"
    done
    $DRY_RUN_CMD install -m755 "${source}/support/lucid/apply-theme.sh" \
      "$lucid_dir/apply-theme-upstream.sh"
    $DRY_RUN_CMD install -m755 ${applyTheme} \
      "$lucid_dir/apply-theme.sh"

    if [ ! -e "$target/lucidprefs/prefs.json" ]; then
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/lucid-prefs.json} "$target/lucidprefs/prefs.json"
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
      $DRY_RUN_CMD install -m644 ${../../../modules/user/lucid/lucid-pinned.json} "$target/luciddocks/pinned.json"
    fi
    if [ ! -e "$target/lucidwidgets/widgets.json" ]; then
      $DRY_RUN_CMD install -m644 ${widgetLayout} "$target/lucidwidgets/widgets.json"
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

  wayland.windowManager.hyprland = {
    settings = {
      on = [ (hyprLua.onStart [ "systemctl --user start lucid.service" ]) ];
      bind = lib.mkIf isRias (lib.mkForce []);
    };
    # Home Manager autoloads these before its generated settings. Lucid's
    # stateful UI modules are installed too, then required after the Nix base
    # config below so saved UI choices take effect without losing that base.
    extraLuaFiles = lib.mkIf isRias {
      "modules/binds.lua" = builtins.toPath "${source}/support/hypr/modules/binds.lua";
      "modules/json.lua" = builtins.toPath "${source}/support/hypr/modules/json.lua";
      "modules/decorations.lua" = builtins.toPath "${source}/support/hypr/modules/decorations.lua";
      "modules/gestures.lua" = builtins.toPath "${source}/support/hypr/modules/gestures.lua";
      "modules/input.lua" = builtins.toPath "${source}/support/hypr/modules/input.lua";
      "modules/layout.lua" = builtins.toPath "${source}/support/hypr/modules/layout.lua";
      "modules/layerrules.lua" = builtins.toPath "${source}/support/hypr/modules/layerrules.lua";
      "modules/lumen.lua" = builtins.toPath "${source}/support/hypr/modules/lumen.lua";
      "modules/misc.lua" = builtins.toPath "${source}/support/hypr/modules/misc.lua";
      "modules/plugins.lua" = builtins.toPath "${source}/support/hypr/modules/plugins.lua";
      "modules/windowrules.lua" = builtins.toPath "${source}/support/hypr/modules/windowrules.lua";
      "modules/glass.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/glass.lua";
        autoLoad = false;
      };
      "modules/monitors.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/monitors.lua";
        autoLoad = false;
      };
      "modules/settings.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/settings.lua";
        autoLoad = false;
      };
      "modules/specials.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/specials.lua";
        autoLoad = false;
      };
      "modules/startup.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/startup.lua";
        autoLoad = false;
      };
    };
    # Nix owns session startup and environment exports; don't load Lucid's
    # generic autostart/env defaults on top of the existing host setup.
    extraConfig = lib.mkIf isRias ''
      local config_home = os.getenv("XDG_CONFIG_HOME") or ${builtins.toJSON config.xdg.configHome}
      package.path = config_home .. "/hypr/?.lua;" .. config_home .. "/hypr/?/init.lua;" .. package.path
      require("modules.specials")
      require("modules.monitors")
      local lucid_monitor_apply = LucidMonitors.apply
      LucidMonitors.apply = function(...)
        lucid_monitor_apply(...)
        hl.monitor({ output = "desc:Huawei Technologies Co. Inc. ZQE-CAA 0xC080F622", cm = "srgb", supports_hdr = -1 })
      end
      LucidMonitors.apply()
      -- Lucid previously left empty workspaces 3-6 persistent on this host.
      -- Retire those stale rules after applying the monitor layout so they do
      -- not return on the next Hyprland reload.
      for _, workspace in ipairs({ "3", "4", "5", "6" }) do
        hl.workspace_rule({ workspace = workspace, persistent = false })
      end
      require("modules.settings")
      require("modules.glass")
      require("modules.startup")
    '';
  };
}
