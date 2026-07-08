{ config, pkgs, pkgs-stable, pkgs-pinned, lib, inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./secrets/secrets.nix
    ./modules/grub.nix
    ./modules/syncthing.nix
    ../modules/thinkpad.nix
    ../modules/gpu/intel.nix

    (import ../modules/common.nix {
      inherit lib;
      inherit inputs;
      hostname = "Inaho";
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

  hardware.usb-modeswitch.enable = true;
  networking.modemmanager.enable = true;
}
