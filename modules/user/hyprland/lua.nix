{ lib }:
let
  inline = lib.generators.mkLuaInline;
  quote = builtins.toJSON;
in rec {
  inherit inline;

  exec = command: "hl.dsp.exec_cmd(${quote command})";

  # Hyprland 0.57 can leave exclusive layer-shell launchers unfocused when
  # follow_mouse = 1 and the pointer is already over a regular window.
  execLauncher = command: ''
    hl.dsp.exec_cmd(${quote ("hyprctl eval 'hl.config({ input = { follow_mouse = 2 } })' && " + command)})
  '';

  bind = keys: dispatcher: {
    _args = [
      keys
      (inline dispatcher)
    ];
  };

  bindWithFlags = keys: dispatcher: flags: {
    _args = [
      keys
      (inline dispatcher)
      flags
    ];
  };

  onStart = commands: {
    _args = [
      "hyprland.start"
      (inline (
        "function()\n"
        + lib.concatMapStringsSep "\n" (command: "  hl.exec_cmd(${quote command})") commands
        + "\nend"
      ))
    ];
  };
}
