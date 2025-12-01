{ config, pkgs, pkgs-unstable, pkgs-fixed, lib, inputs, ...}: {
  imports = [
    ./secrets/secrets.nix
    ./modules/grub.nix
    ./modules/syncthing.nix
    ../../modules/host/adb.nix
    ../modules/gpu/nvidia.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Rias";
    })

    (import ../../user/common.nix {
      inherit config;
      inherit pkgs;
      inherit pkgs-unstable;
      inherit pkgs-fixed;
      inherit lib;
      inherit inputs;
      name = "sweetbread";
      fullname = "Sweet Bread";
    })
  ];

  programs.gamemode.enable = true;
  services.printing.enable = true;
  hardware.opentabletdriver.enable = true;
}
