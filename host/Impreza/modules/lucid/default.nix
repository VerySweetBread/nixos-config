{ config, ... }:
{
  lucid.prefsSeed = ./lucid-prefs-impreza.json;
  lucid.widgetSeed = ./lucid-widgets-impreza.json;
  lucid.initialFiles = {
    "${config.home.homeDirectory}/.config/hypr/lucid-settings.lua" = ./lucid-settings-impreza.lua;
    "${config.home.homeDirectory}/.config/hypr/lucid-glass.lua" = ./lucid-glass-impreza.lua;
  };
}
