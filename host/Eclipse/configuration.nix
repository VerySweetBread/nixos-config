{ config, pkgs, pkgs-stable, pkgs-fixed, lib, inputs, ...}: let
  laptop = false;
in {
  imports = [
    ./secrets/secrets.nix
    ./modules/aagl.nix
    ./modules/grub.nix
    ./modules/zram.nix
    ../modules/gpu/nvidia.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Eclipse";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-stable;
      inherit pkgs-fixed;
      inherit lib;
      inherit inputs;
      inherit laptop;
      name = "chest";
    })
  ];

  nixpkgs.config.allowBroken = true;
  programs.gamemode.enable = true;
}
