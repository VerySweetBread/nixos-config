{ config, lib, osConfig, pkgs, ... }:
let
  host = osConfig.networking.hostName;
  isChest = config.home.username == "chest";
  isRias = host == "Rias";
  specialBindIds = [ "scratchpad" "scratchpad-stash" "special-music" "special-comms" "special-todo" "special-sysmon" "daemons-workspace" ];
  specialSeed = pkgs.writeText "lucid-special-bindings.json" (builtins.toJSON {
    version = 1;
    binds = builtins.filter (entry: builtins.elem entry.id specialBindIds)
      (builtins.fromJSON (builtins.readFile ./lucid-keybinds-rias.json)).binds;
  });
  chestBindingsScript = pkgs.writeText "lucid-chest-bindings.py" ''
import hashlib
import json
import re
import sys
from collections import Counter

source, reference, special, output = sys.argv[1:]
binds = json.loads(source)
refs = json.load(open(reference))["binds"]
specials = json.load(open(special))["binds"]
counts = Counter()
result = []
for entry in binds:
    args = entry["_args"]
    if not 2 <= len(args) <= 3 or args[1].get("_type") != "lua-inline":
        raise ValueError(f"Unsupported Hyprland binding: {entry}")
    keys, expr = args[0], args[1]["expr"]
    opts = args[2] if len(args) == 3 else {}
    signature = json.dumps([keys.upper().replace(" ", ""), opts], sort_keys=True)
    counts[signature] += 1
    identifier = hashlib.sha256(signature.encode()).hexdigest()[:12]
    b = {"id": f"chest-{identifier}-{counts[signature]}", "keys": keys}
    match = next((r for r in refs if r.get("keys", "").upper().replace(" ", "") == keys.upper().replace(" ", "") and r.get("opts", {}) == opts), None)
    b["desc"] = match.get("desc", keys) if match else keys
    b["category"] = match.get("category", "Other") if match else "Other"
    workspace = re.search(r"workspace = (\d+)", expr)
    if workspace and expr.startswith("hl.dsp.focus("):
        b.update(desc=f"Focus workspace {workspace.group(1)}", category="Workspaces")
    elif workspace and expr.startswith("hl.dsp.window.move("):
        b.update(desc=f"Move window to workspace {workspace.group(1)}", category="Workspaces")
    if keys.upper().replace(" ", "") == "SUPER+SHIFT+S":
        b.update(desc="Region screenshot and edit", category="Screenshots")
    m = re.fullmatch(r'hl\.dsp\.exec_cmd\(("(?:\\.|[^"\\])*")\)\s*', expr, re.S)
    if m:
        cmd = json.loads(m.group(1))
        cmd = re.sub(r'/nix/store/[0-9a-z]{32}-[^/\s"\\]+/bin/([A-Za-z0-9_.+-]+)', r'\1', cmd)
        b.update(type="exec", cmd=cmd)
    else:
        b.update(type="lua", lua=expr)
    if opts:
        b["opts"] = opts
    result.append(b)
json.dump({"version": 1, "binds": result + specials}, open(output, "w"), indent=2)
  '';
  chestSeed = pkgs.runCommand "lucid-chest-bindings.json" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 ${chestBindingsScript} ${lib.escapeShellArg (builtins.toJSON config.lucidHyprlandBinds)} \
      ${./lucid-keybinds-rias.json} ${specialSeed} "$out"
  '';
  mergeChestBinds = pkgs.writeText "lucid-merge-chest-bindings.jq" ''
def normlua: (. // "") | gsub("\\s+"; "") | gsub("\u0027"; "\"");
def normkeys: (. // "") | ascii_upcase | gsub("\\s+"; "") | split("+")
  | map(if . == "WIN" or . == "LOGO" or . == "MOD4" then "SUPER"
        elif . == "CONTROL" then "CTRL" else . end) | sort | join("+");
def combos:
  if .each == "workspace" then .keys as $k | [range(1;11) as $i | ($k | gsub("\\{key\\}"; (($i % 10) | tostring)) | normkeys)]
  else [(.keys | normkeys)] end;
def trigger: {click: (.opts.click // false), long_press: (.opts.long_press // false), release: (.opts.release // false), mouse: (.opts.mouse // false)};
if (.binds | type) != "array" then error("keybinds.json has no binds array") else . end
| . as $old
| .binds += [$seed[0].binds[] as $b
  | select([$old.binds[] | select(
      .id == $b.id
      or ((["scratchpad", "scratchpad-stash", "special-music", "special-comms", "special-todo", "special-sysmon", "daemons-workspace"] | index($b.id)) != null and .type == "lua" and $b.type == "lua" and ((.lua | normlua) == ($b.lua | normlua)))
      or ((trigger == ($b | trigger)) and ((combos - ($b | combos) | length) < (combos | length)))
    )] | length == 0) | $b]
  '';
  mergeSpecialBinds = pkgs.writeText "lucid-merge-special-binds.jq" ''
    def normlua: (. // "") | gsub("\\s+"; "") | gsub("\u0027"; "\"");
    def normkeys: (. // "") | ascii_upcase | gsub("\\s+"; "") | split("+")
      | map(if . == "WIN" or . == "LOGO" or . == "MOD4" then "SUPER"
            elif . == "CONTROL" then "CTRL" else . end) | sort | join("+");
    if (.binds | type) != "array" then error("keybinds.json has no binds array") else . end
    | . as $old
    | .binds += [ $seed[0].binds[] as $b
        | select([$old.binds[] | select(.id == $b.id or (.type == "lua" and ((.lua | normlua) == ($b.lua | normlua))))] | length == 0)
        | if ([$old.binds[] | select(.enabled != false and ((.keys | normkeys) == ($b.keys | normkeys)))] | length) > 0
          then $b + { enabled: false } else $b end ]
  '';
  mergeSpecialPrefs = pkgs.writeText "lucid-merge-special-prefs.jq" ''
    .specialCustom = ((.specialCustom // "[]" | fromjson)
      | if type != "array" then error("specialCustom is not an array") else . end
      | if any(.[]; .key == "daemons") then .
        else . + [{key: "daemons", label: "Daemons", glyph: "build", on: true, apps: ""}] end
      | tojson)
  '';
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
  chestBinds = pkgs.runCommand "lucid-chest-loader.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/binds.lua "$out" <<'PYCODE'
import pathlib
import sys
source = pathlib.Path(sys.argv[1]).read_text()
old = '{ id = "terminal", keys = "F9", type = "exec", cmd = "kitty" }'
new = '{ id = "terminal", keys = "SUPER + RETURN", type = "exec", cmd = "ghostty" }'
if source.count(old) != 1:
    raise SystemExit("Lucid emergency bindings changed")
pathlib.Path(sys.argv[2]).write_text(source.replace(old, new, 1))
PYCODE
  '';
  chestMonitors = pkgs.runCommand "lucid-chest-monitors.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/monitors.lua "$out" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text()
default_rule = """hl.monitor({
    output   = "",
    mode     = M.defaults.mode,
    position = M.defaults.position,
    scale    = M.defaults.scale,
})
"""
if source.count(default_rule) != 1:
    raise SystemExit("Lucid monitor defaults changed; refusing to replace host monitor rules")
pathlib.Path(sys.argv[2]).write_text(source.replace(default_rule, "", 1))
PY
  '';
  chestBorders = pkgs.runCommand "lucid-chest-decorations.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/decorations.lua "$out" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text()
marker = "local active_border, inactive_border = borders()"
if source.count(marker) != 1:
    raise SystemExit("Lucid border module changed; refusing to replace host appearance settings")
pathlib.Path(sys.argv[2]).write_text(source.split(marker, 1)[0])
PY
  '';
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
    ];
  };
  wallpaperDir = "${config.home.homeDirectory}/Wallpapers";
  wallpaperScript = "${config.home.homeDirectory}/.config/hypr/scripts/wallpaper/set-wallpaper.sh";
  widgetLayout = if osConfig.networking.hostName == "Rias"
    then ./lucid-widgets-rias.json
    else ./lucid-widgets.json;
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
  chestOsdPatch = pkgs.writeText "lucid-chest-osd.patch" ''
    --- a/lucidosd/Osd.qml
    +++ b/lucidosd/Osd.qml
    @@ -26 +26 @@
    -    readonly property int brightnessPercent: osdWindow.maxBrightness > 0 ? Math.round((parseInt(brightnessFile.text()) / osdWindow.maxBrightness) * 100) : 0
    +    property int brightnessPercent: 0
    @@ -378,2 +378,15 @@
             onFileChanged: reload()
    +        onLoaded: {
    +            const value = parseInt(brightnessFile.text());
    +            if (osdWindow.maxBrightness > 0 && !isNaN(value))
    +                osdWindow.brightnessPercent = Math.round(value / osdWindow.maxBrightness * 100);
    +        }
         }
    +
    +    Timer {
    +        id: chestBrightnessPoll
    +        interval: 500
    +        repeat: true
    +        running: osdWindow.backlightDevice !== ""
    +        onTriggered: brightnessFile.reload()
    +    }
  '';
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
  shellFile = if isChest then pkgs.writeText "lucid-chest-shell.qml" (builtins.replaceStrings [
    ''import "./lucidlock"''
    "    Lock {\n    }\n"
    "        void Clip.probed;"
  ] [
    ""
    ""
    "        void Notifs.count;\n        void KdeConnect.installed;\n        void HyprConfig.moduleProbed;\n        void Monitors.moduleProbed;\n        void Glass.moduleProbed;\n        void Startup.moduleProbed;\n        void Clip.probed;"
  ] (builtins.readFile ./lucid-shell.qml)) else ./lucid-shell.qml;
  prefsFilter = if isChest then
    ''.barEnabled = true | .widgetOnTop = false | .widgetHideFullscreen = true | .fontFamily = $font | .liveWallpapers = false | .idleLock = false | .idleLockBeforeSleep = false | .launcherPowerButtons = "suspend,reboot,shutdown" | .powerModuleActions = "suspend,hibernate,logout,reboot,shutdown"''
  else
    ''.barEnabled = true | .widgetOnTop = false | .widgetHideFullscreen = true | .fontFamily = $font | .wallpaperFolder = $wallpaperDir | .liveDecoder = $decoder'';
  lucid = pkgs.writeShellScript "lucid" ''
    export NIXPKGS_QT6_QML_IMPORT_PATH="${lib.makeSearchPath "lib/qt-6/qml" qmlPackages}:''${NIXPKGS_QT6_QML_IMPORT_PATH:-}"
    export QT_PLUGIN_PATH="${lib.makeSearchPath "lib/qt-6/plugins" qmlPackages}:''${QT_PLUGIN_PATH:-}"
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
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;
  home.packages = with pkgs; [ cliphist ffmpeg grim imagemagick libnotify pywal16 wf-recorder tesseract ]
    ++ lib.optionals isChest [ brightnessctl playerctl slurp swappy ];

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
    ${lib.optionalString isChest ''
    # Notifs refers to Lockscreen even without a lock surface. Keep its
    # singleton from taking over logind lock signals or its LockedHint.
    lock_qml="$target/Lockscreen.qml"
    if ! grep -Fq 'return; // Lucid lock disabled for chest' "$lock_qml"; then
      grep -Fq 'function lock(settle) {' "$lock_qml" && \
        grep -Fq 'function pushLockedHint() {' "$lock_qml" && \
        grep -Fq 'id: logindWatch' "$lock_qml" || {
          echo "Lucid lock integration changed; refusing to leave it active for chest" >&2
          exit 1
        }
      $DRY_RUN_CMD sed -i \
        -e '/function lock(settle) {/a\        return; // Lucid lock disabled for chest' \
        -e '/function pushLockedHint() {/a\        return; // Lucid lock disabled for chest' \
        -e '/id: logindWatch/{n;n;s/running: true/running: false/;}' "$lock_qml"
    fi
    if ! grep -Fq 'id: chestBrightnessPoll' "$target/lucidosd/Osd.qml"; then
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch --forward -p1 -d "$target" < ${chestOsdPatch}
    fi
    ''}
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
    $DRY_RUN_CMD install -m644 ${shellFile} "$target/shell.qml"
    $DRY_RUN_CMD install -m644 ${./LucidBar.qml} "$target/LucidBar.qml"
    ${lib.optionalString (!isChest) ''
    $DRY_RUN_CMD install -m644 ${./Agenda.qml} "$target/Agenda.qml"
    $DRY_RUN_CMD install -m644 ${./CalendarSource.qml} "$target/CalendarSource.qml"
    $DRY_RUN_CMD install -m644 ${./ClockCalendar.qml} "$target/lucidbar/ClockCalendar.qml"
    $DRY_RUN_CMD install -m644 ${./thunderbird-calendar.py} "$target/thunderbird-calendar.py"
    ''}
    $DRY_RUN_CMD install -m644 ${./WidgetLayer.qml} "$target/lucidwidgets/WidgetLayer.qml"
    $DRY_RUN_CMD install -m644 ${./WidgetsPage.qml} "$target/lucidprefs/WidgetsPage.qml"
    ${lib.optionalString (!isChest) ''
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
    if [ "${host}" = Rias ] && [ ! -s "$lucid_dir/keybinds.json" ]; then
      $DRY_RUN_CMD install -m644 ${./lucid-keybinds-rias.json} "$lucid_dir/keybinds.json"
    fi
    ${lib.optionalString (!isRias) ''
    special_migration="$lucid_dir/special-workspaces-v1"
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ ! -e "$special_migration" ]; then
      if [ -f "${config.home.homeDirectory}/.config/hypr/lucid-specials.lua" ] && \
         [ ! -e "${config.home.homeDirectory}/.config/hypr/lucid-specials.before-special-workspaces-v1.lua" ]; then
        cp -p "${config.home.homeDirectory}/.config/hypr/lucid-specials.lua" \
          "${config.home.homeDirectory}/.config/hypr/lucid-specials.before-special-workspaces-v1.lua"
      fi
      if [ ! -s "$lucid_dir/keybinds.json" ]; then
        install -m644 ${specialSeed} "$lucid_dir/keybinds.json"
      else
        binds_tmp=$(${pkgs.coreutils}/bin/mktemp "$lucid_dir/keybinds.json.XXXXXX")
        if ${pkgs.jq}/bin/jq --slurpfile seed ${specialSeed} -f ${mergeSpecialBinds} \
          "$lucid_dir/keybinds.json" > "$binds_tmp"; then
          chmod 644 "$binds_tmp"
          mv "$binds_tmp" "$lucid_dir/keybinds.json"
        else
          rm -f "$binds_tmp"
          echo "Could not merge Lucid special workspace bindings" >&2
          exit 1
        fi
      fi
    fi
    ''}
    ${lib.optionalString isChest ''
    chest_migration="$lucid_dir/chest-keybinds-v1"
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ ! -e "$chest_migration" ]; then
      if [ ! -s "$lucid_dir/keybinds.json" ]; then
        install -m644 ${chestSeed} "$lucid_dir/keybinds.json"
      else
        if [ ! -e "$lucid_dir/keybinds.before-chest-migration.json" ]; then
          cp -p "$lucid_dir/keybinds.json" "$lucid_dir/keybinds.before-chest-migration.json"
        fi
        binds_tmp=$(${pkgs.coreutils}/bin/mktemp "$lucid_dir/keybinds.json.XXXXXX")
        if ${pkgs.jq}/bin/jq --slurpfile seed ${chestSeed} -f ${mergeChestBinds} "$lucid_dir/keybinds.json" > "$binds_tmp"; then
          chmod 644 "$binds_tmp"
          mv "$binds_tmp" "$lucid_dir/keybinds.json"
        else
          rm -f "$binds_tmp"
          echo "Could not migrate chest keybindings to Lucid" >&2
          exit 1
        fi
      fi
      touch "$chest_migration"
    fi
    ''}
    monitor_file="${config.home.homeDirectory}/.config/hypr/lucid-monitors.lua"
    if [ "${host}" = Rias ] && { [ ! -s "$monitor_file" ] || ! grep -qE 'output[[:space:]]*=' "$monitor_file"; } && \
       ! grep -qE 'workspace[[:space:]]*=' "$monitor_file" 2>/dev/null; then
      $DRY_RUN_CMD install -m644 ${./lucid-monitors-rias.lua} "$monitor_file"
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
      $DRY_RUN_CMD install -m644 ${if isChest then "${source}/defaults/prefs.json" else ./lucid-prefs.json} "$target/lucidprefs/prefs.json"
    fi
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ -f "$target/lucidprefs/prefs.json" ]; then
      prefs_tmp=$(${pkgs.coreutils}/bin/mktemp "$target/lucidprefs/prefs.json.XXXXXX")
      if ${pkgs.jq}/bin/jq --arg font ${lib.escapeShellArg config.stylix.fonts.sansSerif.name} \
        --arg wallpaperDir ${lib.escapeShellArg wallpaperDir} \
        --arg decoder ${lib.escapeShellArg liveDecoder} \
        ${lib.escapeShellArg prefsFilter} \
        "$target/lucidprefs/prefs.json" > "$prefs_tmp"; then
        ${pkgs.coreutils}/bin/chmod 644 "$prefs_tmp"
        ${pkgs.coreutils}/bin/mv "$prefs_tmp" "$target/lucidprefs/prefs.json"
      else
        ${pkgs.coreutils}/bin/rm -f "$prefs_tmp"
        exit 1
      fi
    fi
    ${lib.optionalString (!isRias) ''
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ ! -e "$special_migration" ]; then
      prefs_tmp=$(${pkgs.coreutils}/bin/mktemp "$target/lucidprefs/prefs.json.XXXXXX")
      if ${pkgs.jq}/bin/jq -f ${mergeSpecialPrefs} "$target/lucidprefs/prefs.json" > "$prefs_tmp"; then
        chmod 644 "$prefs_tmp"
        mv "$prefs_tmp" "$target/lucidprefs/prefs.json"
        touch "$special_migration"
      else
        rm -f "$prefs_tmp"
        echo "Could not merge Lucid special workspace settings" >&2
        exit 1
      fi
    fi
    ''}
    if [ ! -e "$target/luciddocks/pinned.json" ]; then
      $DRY_RUN_CMD install -m644 ${./lucid-pinned.json} "$target/luciddocks/pinned.json"
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
      ExecStart = "${lucid}";
      Restart = "on-failure";
      RestartSec = 2;
    } // lib.optionalAttrs (!isChest) { ExecStartPre = "${startWallpaper}"; };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  wayland.windowManager.hyprland = {
    settings = {
      on = [ (hyprLua.onStart [ "systemctl --user start lucid.service" ]) ];
      bind = lib.mkIf (isRias || isChest) (lib.mkForce []);
      window_rule = lib.mkIf isChest [
        {
          name = "float-lucid-settings";
          match = { class = "org.quickshell"; title = "Lucid Settings"; };
          float = true;
          size = [ 1180 800 ];
          center = true;
        }
        {
          name = "float-lucid-choosers";
          match = {
            class = "^(org\\.gnome\\.Nautilus|xdg-desktop-portal-gtk|xdg-desktop-portal-gnome|zenity|org\\.kde\\.kdialog|kdialog)$";
            title = "^(Choose an account picture|Choose a template|Choose a colour scheme|Export the palette|Save received files to|Send files|Send to .+)$";
          };
          float = true;
          center = true;
        }
      ];
    };
    # Home Manager autoloads these before its generated settings. Lucid's
    # stateful UI modules are installed too, then required after the Nix base
    # config below so saved UI choices take effect without losing that base.
    extraLuaFiles = {
      "modules/binds.lua" = builtins.toPath (if isRias then "${source}/support/hypr/modules/binds.lua" else if isChest then "${chestBinds}" else "${nonRiasBinds}");
      "modules/json.lua" = builtins.toPath "${source}/support/hypr/modules/json.lua";
      "modules/specials.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/specials.lua";
        autoLoad = false;
      };
    } // lib.optionalAttrs isRias {
      "modules/decorations.lua" = builtins.toPath "${source}/support/hypr/modules/decorations.lua";
      "modules/gestures.lua" = builtins.toPath "${source}/support/hypr/modules/gestures.lua";
      "modules/input.lua" = builtins.toPath "${source}/support/hypr/modules/input.lua";
      "modules/layout.lua" = builtins.toPath "${source}/support/hypr/modules/layout.lua";
      "modules/layerrules.lua" = builtins.toPath "${source}/support/hypr/modules/layerrules.lua";
      "modules/lumen.lua" = builtins.toPath "${source}/support/hypr/modules/lumen.lua";
      "modules/misc.lua" = builtins.toPath "${source}/support/hypr/modules/misc.lua";
      "modules/plugins.lua" = builtins.toPath "${source}/support/hypr/modules/plugins.lua";
      "modules/windowrules.lua" = builtins.toPath "${source}/support/hypr/modules/windowrules.lua";
    } // lib.optionalAttrs isChest {
      "modules/decorations.lua" = builtins.toPath "${chestBorders}";
    } // lib.optionalAttrs (isRias || isChest) {
      "modules/glass.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/glass.lua";
        autoLoad = false;
      };
      "modules/monitors.lua" = {
        content = builtins.toPath (if isChest then "${chestMonitors}" else "${source}/support/hypr/modules/monitors.lua");
        autoLoad = false;
      };
      "modules/settings.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/settings.lua";
        autoLoad = false;
      };
      "modules/startup.lua" = {
        content = builtins.toPath "${source}/support/hypr/modules/startup.lua";
        autoLoad = false;
      };
    };
    # Nix owns session startup and environment exports; don't load Lucid's
    # generic autostart/env defaults on top of the existing host setup.
    extraConfig = ''
      local config_home = os.getenv("XDG_CONFIG_HOME") or ${builtins.toJSON config.xdg.configHome}
      package.path = config_home .. "/hypr/?.lua;" .. config_home .. "/hypr/?/init.lua;" .. package.path
      require("modules.specials")
      LucidSpecials.apply()
    '' + lib.optionalString (isRias || isChest) ''
      require("modules.monitors")
    '' + lib.optionalString isRias ''
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
    '' + lib.optionalString (isRias || isChest) ''
      require("modules.settings")
      require("modules.glass")
      require("modules.startup")
    '';
  };
}
