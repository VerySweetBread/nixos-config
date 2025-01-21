{
  imports = [
    ./bootloader.nix
    ./sound.nix
    ./zram.nix
    ./env.nix
    ./nm.nix
    ./virtmanager.nix
    ./trim.nix
    ./bluetooth.nix
    ./vpn.nix
    ./printing.nix
    ./shutdown-on-lan.nix
  ];

  programs.hyprland.enable = true;
  services.udisks2.enable = true;
}
