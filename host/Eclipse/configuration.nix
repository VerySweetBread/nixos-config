{ config, pkgs, pkgs-stable, lib, inputs, ...}: {
  imports = [
    ./secrets/secrets.nix
    ./modules/aagl.nix
    ./modules/grub.nix
    ./modules/zram.nix
    ../modules/nvidia.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Eclipse";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-stable;
      inherit lib;
      inherit inputs;
      name = "chest";
    })
  ];

  nixpkgs.config.allowBroken = true;
  programs.gamemode.enable = true;
}
