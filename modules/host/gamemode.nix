{ config, pkgs, pkgs-unstable, lib, ... }:

lib.mkIf config.programs.gamemode.enable {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    bottles
    heroic
    prismlauncher
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
