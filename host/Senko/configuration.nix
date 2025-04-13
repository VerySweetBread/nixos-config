{ config, pkgs, pkgs-stable, pkgs-fixed, lib, inputs, ...}: let
  laptop = true;
in {
  imports = [
    ./secrets/secrets.nix
    ./modules/grub.nix
    ../modules/nvidia.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Senko";
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

  hardware.bluetooth.enable = true;
  host.laptop = laptop;

  environment.systemPackages = [ pkgs.dbgate ];
}
