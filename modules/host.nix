{
  imports = [
    ./host/bluetooth.nix
    ./host/bootloader.nix
    ./host/console.nix
    ./host/db.nix
    ./host/env.nix
    ./host/gamemode.nix
    ./host/gpg.nix
    ./host/laptop.nix
    ./host/printing.nix
    ./host/shutdown-on-lan.nix
    ./host/sound.nix
    ./host/virtmanager.nix
    ./host/vpn.nix
    ./host/network.nix
  ];

  programs.hyprland.enable = true;
  services = {
    udisks2.enable = true;
    fstrim.enable = true;
    upower.enable = true;
  };
}
