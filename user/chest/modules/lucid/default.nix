{ config, lib, pkgs, ... }:
let
  source = config.lucid.upstreamSource;
  specialBindIds = [ "scratchpad" "scratchpad-stash" "special-music" "special-comms" "special-todo" "special-sysmon" "daemons-workspace" ];
  specialSeed = pkgs.writeText "lucid-special-bindings.json" (builtins.toJSON {
    version = 1;
    binds = builtins.filter (entry: builtins.elem entry.id specialBindIds)
      (builtins.fromJSON (builtins.readFile ../../../../modules/user/lucid/lucid-keybind-catalog.json)).binds;
  });
  chestBindingsScript = pkgs.writeText "lucid-chest-bindings.py" ''
import hashlib, json, re, sys
from collections import Counter
source, reference, special, output = sys.argv[1:]
binds = json.loads(source)
refs = json.load(open(reference))["binds"]
specials = json.load(open(special))["binds"]
counts, result = Counter(), []
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
    if keys.upper().replace(" ", "") == "SUPER+SHIFT+S": b.update(desc="Region screenshot and edit", category="Screenshots")
    m = re.fullmatch(r'hl\.dsp\.exec_cmd\(("(?:\\.|[^"\\])*")\)\s*', expr, re.S)
    if m:
        cmd = json.loads(m.group(1))
        cmd = re.sub(r'/nix/store/[0-9a-z]{32}-[^/\s"\\]+/bin/([A-Za-z0-9_.+-]+)', r'\1', cmd)
        b.update(type="exec", cmd=cmd)
    else: b.update(type="lua", lua=expr)
    if opts: b["opts"] = opts
    result.append(b)
json.dump({"version": 1, "binds": result + specials}, open(output, "w"), indent=2)
  '';
  chestSeed = pkgs.runCommand "lucid-chest-bindings.json" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 ${chestBindingsScript} ${lib.escapeShellArg (builtins.toJSON config.lucidHyprlandBinds)} \
      ${../../../../modules/user/lucid/lucid-keybind-catalog.json} ${specialSeed} "$out"
  '';
  chestBinds = pkgs.runCommand "lucid-chest-loader.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/binds.lua "$out" <<'PY'
import pathlib, sys
source = pathlib.Path(sys.argv[1]).read_text()
old = '{ id = "terminal", keys = "F9", type = "exec", cmd = "kitty" }'
new = '{ id = "terminal", keys = "SUPER + RETURN", type = "exec", cmd = "ghostty" }'
if source.count(old) != 1: raise SystemExit("Lucid emergency bindings changed")
pathlib.Path(sys.argv[2]).write_text(source.replace(old, new, 1))
PY
  '';
  chestMonitors = pkgs.runCommand "lucid-chest-monitors.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/monitors.lua "$out" <<'PY'
import pathlib, sys
source = pathlib.Path(sys.argv[1]).read_text()
rule = """hl.monitor({
    output   = "",
    mode     = M.defaults.mode,
    position = M.defaults.position,
    scale    = M.defaults.scale,
})
"""
if source.count(rule) != 1: raise SystemExit("Lucid monitor defaults changed")
pathlib.Path(sys.argv[2]).write_text(source.replace(rule, "", 1))
PY
  '';
  chestBorders = pkgs.runCommand "lucid-chest-decorations.lua" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - ${source}/support/hypr/modules/decorations.lua "$out" <<'PY'
import pathlib, sys
source = pathlib.Path(sys.argv[1]).read_text()
marker = "local active_border, inactive_border = borders()"
if source.count(marker) != 1: raise SystemExit("Lucid border module changed")
pathlib.Path(sys.argv[2]).write_text(source.split(marker, 1)[0])
PY
  '';
  chestPrefs = pkgs.writeText "lucid-chest-prefs.json" (builtins.toJSON (
    (builtins.fromJSON (builtins.readFile "${source}/defaults/prefs.json")) // {
      specialCustom = builtins.toJSON [ { key = "daemons"; label = "Daemons"; glyph = "build"; on = true; apps = ""; } ];
    }
  ));
in
{
  lucid.keybindSeed = chestSeed;
  lucid.prefsSeed = chestPrefs;
  lucid.bindsModule = chestBinds;
  lucid.luaModules = {
    "modules/decorations.lua" = lib.mkForce chestBorders;
    "modules/monitors.lua" = lib.mkForce { content = chestMonitors; autoLoad = false; };
    "modules/glass.lua" = { content = "${source}/support/hypr/modules/glass.lua"; autoLoad = false; };
    "modules/settings.lua" = { content = "${source}/support/hypr/modules/settings.lua"; autoLoad = false; };
    "modules/startup.lua" = { content = "${source}/support/hypr/modules/startup.lua"; autoLoad = false; };
  };
  lucid.extraHyprlandConfig = ''
    require("modules.monitors")
    require("modules.settings")
    require("modules.glass")
    require("modules.startup")
  '';
  lucid.shellFile = pkgs.writeText "lucid-chest-shell.qml" (builtins.replaceStrings [
    ''import "./lucidlock"''
    "    Lock {\n    }\n"
    "        void Clip.probed;"
  ] [
    ""
    ""
    "        void Notifs.count;\n        void KdeConnect.installed;\n        void HyprConfig.moduleProbed;\n        void Monitors.moduleProbed;\n        void Glass.moduleProbed;\n        void Startup.moduleProbed;\n        void Clip.probed;"
  ] (builtins.readFile ../../../../modules/user/lucid/lucid-shell.qml));

  lucid.prefsFilter = ''.barEnabled = true | .widgetOnTop = false | .widgetHideFullscreen = true | .fontFamily = $font | .liveWallpapers = false | .idleLock = false | .idleLockBeforeSleep = false | .launcherPowerButtons = "suspend,reboot,shutdown" | .powerModuleActions = "suspend,hibernate,logout,reboot,shutdown"'';

  home.packages = with pkgs; [ brightnessctl playerctl slurp swappy ];

  wayland.windowManager.hyprland.settings = {
    bind = lib.mkForce [];
    window_rule = [
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

  home.activation.installChestLucidFixes = lib.hm.dag.entryAfter [ "installLucid" ] ''
    target="${config.home.homeDirectory}/.config/quickshell"
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
      $DRY_RUN_CMD ${pkgs.patch}/bin/patch --batch --forward -p1 -d "$target" < ${pkgs.writeText "lucid-chest-osd.patch" ''
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
      ''}
    fi
  '';
}
