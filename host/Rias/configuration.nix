{ config, pkgs, pkgs-stable, pkgs-fixed, lib, inputs, ...}: let
  laptop = false;
in {
  imports = [
    ./secrets/secrets.nix
    ./modules/grub.nix
    ./modules/syncthing.nix
    ../../modules/host/adb.nix
    ../modules/nvidia.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Rias";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-stable;
      inherit pkgs-fixed;
      inherit lib;
      inherit inputs;
      inherit laptop;
      name = "sweetbread";
      fullname = "Sweet Bread";
    })
  ];

  programs.gamemode.enable = true;
}
