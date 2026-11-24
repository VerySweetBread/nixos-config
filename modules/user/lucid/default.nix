{ config, lib, pkgs, ... }:
let
  staticBindKeys = map (entry: builtins.elemAt entry._args 0) config.wayland.windowManager.hyprland.settings.bind;
  nonRiasBinds = pkgs.runCommand "lucid-nix-binds.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/binds.lua "$out" ${lib.escapeShellArg (builtins.toJSON staticBindKeys)} <<'PY'
import json
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text()
keys = json.loads(sys.argv[3])
lua_keys = "{ " + ", ".join(json.dumps(key, ensure_ascii=True) for key in keys) + " }"
guard = r"""
local function normalize_nix_bind(keys)
    local mods, key = {}, ""
    for part in tostring(keys or ""):gmatch("[^+]+") do
        local token = (part:match("^%s*(.-)%s*$") or ""):upper()
        if token == "CONTROL" then token = "CTRL" end
        if token == "WIN" or token == "LOGO" or token == "MOD4" then token = "SUPER" end
        if token == "SUPER" or token == "CTRL" or token == "ALT" or token == "SHIFT" then
            mods[token] = true
        else
            key = token
        end
    end
    local out = {}
    for _, mod in ipairs({"ALT", "CTRL", "SHIFT", "SUPER"}) do
        if mods[mod] then out[#out + 1] = mod end
    end
    return table.concat(out, "+") .. "+" .. key
end
local nix_binds = {}
for _, key in ipairs(NIX_BIND_KEYS) do nix_binds[normalize_nix_bind(key)] = true end
""".replace("NIX_BIND_KEYS", lua_keys)
marker = "-- several dispatchers on one key, in order"
binding = '    if type(keys) ~= "string" or keys == "" then error("no keys", 0) end'
fallback = '    for _, entry in ipairs(EMERGENCY) do apply(entry) end'
fallback_source = '    status.source = "emergency"'
fallback_text = 'Emergency binds are active - SUPER+S opens Settings.'
for needle in (marker, binding, fallback, fallback_source, fallback_text):
    if source.count(needle) != 1:
        raise SystemExit("Lucid bind loader changed; refusing to skip conflict protection")
source = source.replace(marker, guard + "\n" + marker, 1)
source = source.replace(binding, binding + '\n    if nix_binds[normalize_nix_bind(keys)] then error("Already bound by Nix: " .. keys, 0) end', 1)
source = source.replace(fallback, '    -- Nix supplies the fallback keys on these hosts.', 1)
source = source.replace(fallback_source, '    status.source = "nix"', 1)
source = source.replace(fallback_text, 'Nix bindings remain active.', 1)
pathlib.Path(sys.argv[2]).write_text(source)
PY
  '';
  vaultwardenLauncherPatch = pkgs.writeText "lucid-vaultwarden-launcher.py" ''
import pathlib
import sys

face_path, dock_path = map(pathlib.Path, sys.argv[1:])
face = face_path.read_text()
dock = dock_path.read_text()

def replace_once(source, old, new, label):
    count = source.count(old)
    if count != 1:
        raise SystemExit(f"Lucid {label} anchor changed (found {count}); refusing an unsafe launcher patch")
    return source.replace(old, new, 1)

face = replace_once(face,
    '        "clipboard": "Search clipboard history",\n',
    '        "clipboard": "Search clipboard history",\n        "vaultwarden": "Search Vaultwarden",\n', "launcher placeholder")
face = replace_once(face,
    '        "clipboard": "content_paste",\n',
    '        "clipboard": "content_paste",\n        "vaultwarden": "key",\n', "launcher icon")
face = replace_once(face,
    '        "icon": "content_paste"\n    }, {\n        "key": "wallpaper",',
    '        "icon": "content_paste"\n    }, {\n        "key": "vaultwarden",\n        "label": "Vaultwarden",\n        "icon": "key"\n    }, {\n        "key": "wallpaper",', "launcher mode")
face = replace_once(face,
    '            emptyLabel: {\n',
    '            emptyLabel: {\n                if (face.displayMode === "vaultwarden")\n                    return "No matching vault entries";\n', "launcher empty label")
face = replace_once(face,
    '            emptyHint: {\n',
    '            emptyHint: {\n                if (face.displayMode === "vaultwarden")\n                    return "Unlock the vault with rbw, then search by name, username, or folder.";\n', "launcher empty hint")

dock = replace_once(dock,
    '        if (q.indexOf(">clip") === 0)\n            return "clipboard";\n',
    '        if (q.indexOf(">clip") === 0)\n            return "clipboard";\n\n        if (q.indexOf(">pass") === 0)\n            return "vaultwarden";\n', "launcher prefix")
dock = replace_once(dock,
    '        if (mode === "clipboard")\n            return ">clip";\n',
    '        if (mode === "clipboard")\n            return ">clip ";\n\n        if (mode === "vaultwarden")\n            return ">pass ";\n', "launcher mode prefix")
dock = replace_once(dock,
    '        if (mode === "wallpaper")\n            return ">wallpaper";\n',
    '        if (mode === "wallpaper")\n            return ">wallpaper ";\n', "wallpaper prefix spacing")
dock = replace_once(dock,
    '        if (mode === "theme")\n            return ">theme";\n',
    '        if (mode === "theme")\n            return ">theme ";\n', "theme prefix spacing")
dock = replace_once(dock,
    '        if (mode === "live")\n            return ">live";\n',
    '        if (mode === "live")\n            return ">live ";\n', "live prefix spacing")
dock = replace_once(dock,
    '        if (mode === "commands")\n            return ">";\n',
    '        if (mode === "commands")\n            return "> ";\n', "command prefix spacing")
dock = replace_once(dock,
    '        if (text === ">wallpaper" && !exact && Prefs.liveWallpapers && LiveWall.isVideo(dockWindow.appliedWallpaper))\n            text = ">live";\n',
    '        if (text.trim() === ">wallpaper" && !exact && Prefs.liveWallpapers && LiveWall.isVideo(dockWindow.appliedWallpaper))\n            text = ">live ";\n', "wallpaper live prefix spacing")
dock = replace_once(dock,
    '            dockWindow.setSearchText(">wallpaper");\n        } else if (id === "theme") {\n            dockWindow.setSearchText(">theme");\n',
    '            dockWindow.setSearchText(">wallpaper ");\n        } else if (id === "theme") {\n            dockWindow.setSearchText(">theme ");\n', "menu prefix spacing")
dock = replace_once(dock,
    '        } else if (id === "clipboard") {\n            dockWindow.setSearchText(">clip");\n',
    '        } else if (id === "clipboard") {\n            dockWindow.setSearchText(">clip ");\n', "clipboard prefix spacing")
dock = replace_once(dock,
    '                dockWindow.setSearchText(">wallpaper", true);',
    '                dockWindow.setSearchText(">wallpaper ", true);', "wallpaper picker prefix spacing")
dock = replace_once(dock,
    'onPickerKindRequested: (kind) => dockWindow.setSearchText(kind === "live" ? ">live" : ">wallpaper", true)',
    'onPickerKindRequested: (kind) => dockWindow.setSearchText(kind === "live" ? ">live " : ">wallpaper ", true)', "picker tab prefix spacing")
dock = replace_once(dock,
    '            dockWindow.openLauncher(">wallpaper");\n        }\n\n        function live(): void {\n            dockWindow.openLauncher(">live");',
    '            dockWindow.openLauncher(">wallpaper ");\n        }\n\n        function live(): void {\n            dockWindow.openLauncher(">live ");', "wallpaper ipc prefix spacing")
dock = replace_once(dock,
    'onBackRequested: dockWindow.setSearchText(dockWindow.mode === "commands" ? "" : ">")',
    'onBackRequested: dockWindow.setSearchText(dockWindow.mode === "commands" ? "" : "> ")', "back prefix spacing")
dock = replace_once(dock,
    '        if (dockWindow.mode === "clipboard")\n            Clip.refresh();\n',
    '        if (dockWindow.mode === "clipboard")\n            Clip.refresh();\n        if (dockWindow.mode === "vaultwarden")\n            Vaultwarden.refresh();\n', "launcher mode activation")
dock = replace_once(dock,
    '    readonly property var allCommands: [{',
    """    Connections {
        target: Vaultwarden

        function onEntriesChanged() { dockWindow.rebuildResults(); }
        function onLoadingChanged() { dockWindow.rebuildResults(); }
        function onErrorChanged() { dockWindow.rebuildResults(); }
        function onPasswordReady(password, targetAddress) {
            dockWindow.menuOpen = false;
            Vaultwarden.typePassword(password, targetAddress);
        }
    }

    readonly property var allCommands: [{""", "vaultwarden updates")
dock = replace_once(dock,
    '    function rebuildResults() {',
    """    function vaultRows(query) {
        if (Vaultwarden.loading)
            return [dockWindow.headerRow("Loading Vaultwarden…")];
        if (Vaultwarden.error !== "")
            return [dockWindow.headerRow(Vaultwarden.error)];

        var rows = [];
        var entries = Vaultwarden.entries || [];
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            var haystack = (entry.name + " " + entry.user + " " + entry.folder).toLowerCase();
            if (query !== "" && haystack.indexOf(query) === -1)
                continue;
            var detail = [entry.user, entry.folder].filter((part) => part !== "").join(" · ");
            rows.push(dockWindow.makeRow("vaultwarden", "vault-" + entry.id, entry.name, detail, {
                "glyph": "key",
                "payload": entry.id
            }));
        }
        return rows;
    }

    function rebuildResults() {""", "vaultwarden search")
dock = replace_once(dock,
    '        } else if (mode === "clipboard") {\n            var ents = Clip.entries;',
    '        } else if (mode === "vaultwarden") {\n            rows = dockWindow.vaultRows(q);\n        } else if (mode === "clipboard") {\n            var ents = Clip.entries;', "vaultwarden results")
dock = replace_once(dock,
    '        } else if (row.kind === "clip") {\n            Clip.copy(row.payload);\n            dockWindow.menuOpen = false;\n',
    '        } else if (row.kind === "clip") {\n            Clip.copy(row.payload);\n            dockWindow.menuOpen = false;\n        } else if (row.kind === "vaultwarden") {\n            Vaultwarden.getPassword(row.payload, Hyprland.activeToplevel ? Hyprland.activeToplevel.address : "");\n', "vaultwarden selection")

face_path.write_text(face)
dock_path.write_text(dock)
  '';
  baseSource = pkgs.applyPatches {
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
    patches = [
      (pkgs.writeText "lucid-scratchpad-target.patch" ''
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
      '')
      (pkgs.writeText "lucid-nonpersistent-workspaces.patch" ''
      diff --git a/support/hypr/modules/gestures.lua b/support/hypr/modules/gestures.lua
      --- a/support/hypr/modules/gestures.lua
      +++ b/support/hypr/modules/gestures.lua
      @@ -6,9 +6,5 @@
       hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
       hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

      --- Pre-create workspaces 1-5 so gesture swipes can always live-track to them
      -for i = 1, 6 do
      -    hl.workspace_rule({ workspace = tostring(i), persistent = true })
      -end

       -- local function minimize_all()
      '')
      (pkgs.writeText "lucid-lair-search.patch" ''
        --- a/luciddocks/Dock.qml
        +++ b/luciddocks/Dock.qml
        @@ -683,4 +683,8 @@
             readonly property var searchEngines: ({
        +        "lair": {
        +            "name": "Lair",
        +            "url": "https://s.lair.moe/web?s="
        +        },
                 "duckduckgo": {
                     "name": "DuckDuckGo",
                     "url": "https://duckduckgo.com/?q="
        --- a/lucidprefs/LauncherPage.qml
        +++ b/lucidprefs/LauncherPage.qml
        @@ -386,5 +386,8 @@
                         current: Prefs.launcherSearchEngine
                         options: [{
        +                    "key": "lair",
        +                    "label": "Lair"
        +                }, {
                             "key": "duckduckgo",
                             "label": "DuckDuckGo"
                         }, {
      '')
      (pkgs.writeText "lucid-shot-special-workspace-name.patch" ''
        diff --git a/lucidshot/ShotOverlay.qml b/lucidshot/ShotOverlay.qml
        --- a/lucidshot/ShotOverlay.qml
        +++ b/lucidshot/ShotOverlay.qml
        @@ -228,1 +228,1 @@
        -        const ws = mon.activeWorkspace ? mon.activeWorkspace.id : null;
        +        const ws = mon.activeWorkspace ? mon.activeWorkspace.name : null;
        @@ -229,1 +229,1 @@
        -        const special = mon.specialWorkspace ? mon.specialWorkspace.id : 0;
        +        const special = mon.specialWorkspace ? mon.specialWorkspace.name : "";
        @@ -234,1 +234,1 @@
        -            return c.workspace.id === ws || (special !== 0 && c.workspace.id === special) || (c.pinned && c.monitor === mon.id);
        +            return c.workspace.name === ws || (special && c.workspace.name === special) || (c.pinned && c.monitor === mon.id);
        @@ -246,1 +246,1 @@
        -                "special": special !== 0 && c.workspace.id === special,
        +                "special": !!special && c.workspace.name === special,
      '')
      ./battery-widget.patch
      ./battery-widget-variants.patch
      fingerprintPamPatch
    ];
  };
  source = pkgs.runCommand "lucid-vaultwarden-launcher-source" {
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    cp -r ${baseSource} "$out"
    chmod -R u+w "$out"
    python3 ${vaultwardenLauncherPatch} "$out/luciddocks/LauncherFace.qml" "$out/luciddocks/Dock.qml"
  '';
  wallpaperDir = "${config.home.homeDirectory}/Wallpapers";
  wallpaperScript = "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper/set-wallpaper.sh";
  defaultWallpaper = "${wallpaperDir}/bluehour.jpg";
  hyprLua = import ../hyprland/lua.nix { inherit lib; };
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
  fingerprintPamPatch = pkgs.writeText "lucid-fingerprint-pam.patch" ''
    --- a/pam/fingerprint
    +++ b/pam/fingerprint
    @@ -1 +1 @@
    -auth required pam_fprintd.so max-tries=1 timeout=60
    +auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so max-tries=1 timeout=60
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
    export GI_TYPELIB_PATH="${pkgs.gdk-pixbuf}/lib/girepository-1.0:''${GI_TYPELIB_PATH:-}"
    export PATH="${lib.makeBinPath (with pkgs; [ bash brightnessctl cliphist coreutils curl ffmpeg grim imagemagick jq libnotify pulseaudio kdeConnectBridgePython pywal16 wf-recorder wl-clipboard xdg-utils ])}:${tesseract}/bin:$PATH"
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
  options.lucid = {
    upstreamSource = lib.mkOption {
      type = lib.types.path;
      default = source;
      description = "Patched Lucid source tree used by profile modules.";
    };
    keybindSeed = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional initial Lucid keybinding file.";
    };
    prefsSeed = lib.mkOption {
      type = lib.types.path;
      default = "${source}/defaults/prefs.json";
      description = "Initial Lucid preferences file.";
    };
    widgetSeed = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional initial Lucid widget layout.";
    };
    initialFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = "Files to seed once at their absolute destinations.";
    };
    managedFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = "Lucid files installed at their absolute destinations.";
    };
    prefsFilter = lib.mkOption {
      type = lib.types.lines;
      default = ''.barEnabled = true | .widgetOnTop = false | .widgetHideFullscreen = true | .fontFamily = $font | .wallpaperFolder = $wallpaperDir | .liveDecoder = $decoder'';
      description = "Declarative jq updates applied to Lucid preferences.";
    };
    liveDecoder = lib.mkOption {
      type = lib.types.str;
      default = "vaapi";
      description = "Hardware decoder used by Lucid wallpaper playback.";
    };
    bindsModule = lib.mkOption {
      type = lib.types.path;
      default = nonRiasBinds;
      description = "Lua module that loads this profile's Hyprland bindings.";
    };
    luaModules = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional Lucid Hyprland Lua modules for this profile.";
    };
    extraHyprlandConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Profile-specific Hyprland Lua configuration loaded after the shared Lucid setup.";
    };
    startWallpaper = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Apply the configured wallpaper before Lucid starts.";
    };
    installWallpaperSupport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Lucid wallpaper integration scripts.";
    };
    shellFile = lib.mkOption {
      type = lib.types.path;
      default = ./lucid-shell.qml;
      description = "Lucid Quickshell entry point for this user profile.";
    };
  };

  config = {
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
    $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch -p1 -d "$target" < ${./idle-work.patch}
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
    $DRY_RUN_CMD install -m644 ${config.lucid.shellFile} "$target/shell.qml"
    $DRY_RUN_CMD install -m644 ${./LucidBar.qml} "$target/LucidBar.qml"
    $DRY_RUN_CMD install -m644 ${./Vaultwarden.qml} "$target/Vaultwarden.qml"
    $DRY_RUN_CMD install -m644 ${./WidgetLayer.qml} "$target/lucidwidgets/WidgetLayer.qml"
    $DRY_RUN_CMD install -m644 ${./WidgetsPage.qml} "$target/lucidprefs/WidgetsPage.qml"
    ${lib.optionalString config.lucid.installWallpaperSupport ''
    $DRY_RUN_CMD mkdir -p "${wallpaperDir}" \
      "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper"
    $DRY_RUN_CMD install -m755 "${source}/support/wallpaper/set-wallpaper.sh" \
      "${wallpaperScript}"
    if ! grep -Fq 'CURRENT_THEME" == matugen' "${wallpaperScript}"; then
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch --forward -p1 -d "$(dirname ${lib.escapeShellArg wallpaperScript})" < ${wallpaperAutoPatch}
    fi
    ''}

    lucid_dir="${config.home.homeDirectory}/.config/lucid"
    $DRY_RUN_CMD mkdir -p "$lucid_dir/themes"
    if [ ! -s "$lucid_dir/keybinds.json" ]; then
      ${lib.optionalString (config.lucid.keybindSeed != null) ''$DRY_RUN_CMD install -m644 ${config.lucid.keybindSeed} "$lucid_dir/keybinds.json"''}
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
      $DRY_RUN_CMD install -m644 ${config.lucid.prefsSeed} "$target/lucidprefs/prefs.json"
    fi
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ -f "$target/lucidprefs/prefs.json" ]; then
      prefs_tmp=$(${pkgs.coreutils}/bin/mktemp "$target/lucidprefs/prefs.json.XXXXXX")
      if ${pkgs.jq}/bin/jq --arg font ${lib.escapeShellArg config.stylix.fonts.sansSerif.name} \
        --arg wallpaperDir ${lib.escapeShellArg wallpaperDir} \
        --arg decoder ${lib.escapeShellArg config.lucid.liveDecoder} \
        ${lib.escapeShellArg config.lucid.prefsFilter} \
        "$target/lucidprefs/prefs.json" > "$prefs_tmp"; then
        ${pkgs.coreutils}/bin/chmod 644 "$prefs_tmp"
        ${pkgs.coreutils}/bin/mv "$prefs_tmp" "$target/lucidprefs/prefs.json"
      else
        ${pkgs.coreutils}/bin/rm -f "$prefs_tmp"
        exit 1
      fi
    fi
    ${lib.optionalString (config.lucid.widgetSeed != null) ''
    if [ ! -e "$target/lucidwidgets/widgets.json" ]; then
      $DRY_RUN_CMD install -m644 ${config.lucid.widgetSeed} "$target/lucidwidgets/widgets.json"
    fi
    ''}
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (destination: sourceFile: ''
    if [ ! -e ${lib.escapeShellArg destination} ]; then
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg (builtins.dirOf destination)}
      $DRY_RUN_CMD install -m644 ${sourceFile} ${lib.escapeShellArg destination}
    fi
    '') config.lucid.initialFiles)}
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (destination: sourceFile: ''
    $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg (builtins.dirOf destination)}
    $DRY_RUN_CMD install -m644 ${sourceFile} ${lib.escapeShellArg destination}
    '') config.lucid.managedFiles)}

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
      ExecStart = "${lucid}";
      Restart = "on-failure";
      RestartSec = 2;
    } // lib.optionalAttrs config.lucid.startWallpaper { ExecStartPre = "${startWallpaper}"; };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  wayland.windowManager.hyprland = {
    settings = {
      on = [ (hyprLua.onStart [ "systemctl --user start lucid.service" ]) ];
    };
    # Home Manager autoloads these before its generated settings. Lucid's
    # stateful UI modules are installed too, then required after the Nix base
    # config below so saved UI choices take effect without losing that base.
    extraLuaFiles = {
      "modules/binds.lua" = config.lucid.bindsModule;
      "modules/json.lua" = builtins.toPath "${source}/support/hypr/modules/json.lua";
      "modules/specials.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/specials.lua";
        autoLoad = false;
      };
    } // config.lucid.luaModules;
    # Nix owns session startup and environment exports; don't load Lucid's
    # generic autostart/env defaults on top of the existing host setup.
    extraConfig = ''
      local config_home = os.getenv("XDG_CONFIG_HOME") or ${builtins.toJSON config.xdg.configHome}
      package.path = config_home .. "/hypr/?.lua;" .. config_home .. "/hypr/?/init.lua;" .. package.path
      require("modules.specials")
      LucidSpecials.apply()
    '' + config.lucid.extraHyprlandConfig;
  };
  };
}
