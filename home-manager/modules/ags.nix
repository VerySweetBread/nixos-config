{ inputs, pkgs, ... }: {
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;

    configDir = ./ags;

    extraPackages = with inputs.ags.packages.${pkgs.system}; [
      battery
      mpris
      hyprland
      network
      tray
      wireplumber
    ];
  };

  wayland.windowManager.hyprland.settings.exec-once = [ "ags run" ];
}
