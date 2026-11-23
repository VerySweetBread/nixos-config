{ config, lib, osConfig, ... }:
{
  lucid.prefsSeed = lib.mkForce (builtins.toFile "sweetbread-rias-lucid-prefs.json" (builtins.toJSON (
    (builtins.fromJSON (builtins.readFile ./lucid-prefs.json)) // {
      specialCustom = "[]";
    }
  )));
  lucid.extraHyprlandConfig = ''
    require("modules.monitors")
    require("modules.settings")
    require("modules.glass")
    require("modules.startup")
  '';
}
