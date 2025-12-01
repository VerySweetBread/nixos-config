{ config, pkgs, pkgs-stable, pkgs-pinned, lib, inputs, ... }: {
  imports = [
    ./secrets/secrets.nix
    ./modules/grub.nix
    ../modules/gpu/nvidia.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Senko";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-stable;
      inherit pkgs-pinned;
      inherit lib;
      inherit inputs;
      name = "sweetbread";
      fullname = "Sweet Bread";
    })
  ];

  hardware.bluetooth.enable = true;
  host.laptop = true;

  environment.systemPackages = [ pkgs.dbgate ];
}
