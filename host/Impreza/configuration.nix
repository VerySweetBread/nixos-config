{ config, pkgs, pkgs-stable, pkgs-fixed, lib, inputs, ...}: {
  imports = [
    ./secrets/secrets.nix
    ./modules/grub.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Impreza";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-stable;
      inherit pkgs-fixed;
      inherit lib;
      inherit inputs;
      name = "chest";
    })
  ];

  nixpkgs.config.allowBroken = true;
  programs.gamemode.enable = true;
  hardware.bluetooth.enable = true;
  host.laptop = true;
}
