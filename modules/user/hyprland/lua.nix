{ lib }:
let
  inline = lib.generators.mkLuaInline;
  quote = builtins.toJSON;
in rec {
  inherit inline;

  exec = command: "hl.dsp.exec_cmd(${quote command})";

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
