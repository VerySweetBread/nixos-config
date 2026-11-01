{ pkgs, inputs, lib, config, ... }: {
  imports = [
    ./host/bluetooth.nix
    ./host/bootloader.nix
    ./host/console.nix
    ./host/db.nix
    ./host/env.nix
    ./host/gamemode.nix
    ./host/gpg.nix
    ./host/laptop.nix
    ./host/network.nix
    ./host/printing.nix
    ./host/shutdown-on-lan.nix
    ./host/sound.nix
    ./host/virtmanager.nix
    ./host/vpn.nix
    ./host/yggdrasil.nix
    ./host/mtp.nix
  ];

  programs = {
    dconf.enable = true;
    hyprland.enable = true;
    hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  security.wrappers.Hyprland.source = lib.mkForce
    "${config.programs.hyprland.package}/bin/.Hyprland-wrapped";

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];

    config = {
      common = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };

      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };

  services = {
    fstrim.enable = true;
    upower.enable = true;
  };
}
