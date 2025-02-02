{ config, pkgs, pkgs-stable, lib, inputs, ...}: {
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
      inherit lib;
      inherit inputs;
      name = "sweetbread";
      fullname = "Sweet Bread";
    })
  ];

  hardware.bluetooth.enable = true;
  host.laptop = true;
}
