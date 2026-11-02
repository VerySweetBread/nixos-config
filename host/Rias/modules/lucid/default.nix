{ config, lib, ... }:
{
  lucid.widgetSeed = ./lucid-widgets-rias.json;
  lucid.liveDecoder = "cuda";
  lucid.bindsModule = lib.mkDefault "${config.lucid.upstreamSource}/support/hypr/modules/binds.lua";
  lucid.luaModules = {
    "modules/decorations.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/decorations.lua";
    "modules/gestures.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/gestures.lua";
    "modules/input.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/input.lua";
    "modules/layout.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/layout.lua";
    "modules/layerrules.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/layerrules.lua";
    "modules/lumen.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/lumen.lua";
    "modules/misc.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/misc.lua";
    "modules/plugins.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/plugins.lua";
    "modules/windowrules.lua" = "${config.lucid.upstreamSource}/support/hypr/modules/windowrules.lua";
    "modules/monitors.lua" = { content = "${config.lucid.upstreamSource}/support/hypr/modules/monitors.lua"; autoLoad = false; };
    "modules/glass.lua" = { content = "${config.lucid.upstreamSource}/support/hypr/modules/glass.lua"; autoLoad = false; };
    "modules/settings.lua" = { content = "${config.lucid.upstreamSource}/support/hypr/modules/settings.lua"; autoLoad = false; };
    "modules/startup.lua" = { content = "${config.lucid.upstreamSource}/support/hypr/modules/startup.lua"; autoLoad = false; };
  };
}
