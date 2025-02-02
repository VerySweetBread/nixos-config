{ config, pkgs, pkgs-stable, lib, ... }:

lib.mkIf config.programs.gamemode.enable {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs-stable; [
    mangohud
    protonup
    pkgs.bottles
    heroic
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
