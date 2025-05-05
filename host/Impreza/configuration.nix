{ config, pkgs, pkgs-unstable, pkgs-fixed, lib, inputs, ...}: let
  laptop = true;
in {
  imports = [
    ./secrets/secrets.nix
    ./modules/grub.nix
    ../modules/gpu/intel.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Impreza";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-unstable;
      inherit pkgs-fixed;
      inherit lib;
      inherit inputs;
      inherit laptop;
      name = "chest";
    })
  ];

  nixpkgs.config.allowBroken = true;
  programs.gamemode.enable = true;
  hardware.bluetooth.enable = true;
  host.laptop = laptop;
}
