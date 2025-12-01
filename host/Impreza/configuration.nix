{ config, pkgs, pkgs-stable, pkgs-pinned, lib, inputs, ... }: {
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
      inherit pkgs-stable;
      inherit pkgs-pinned;
      inherit lib;
      inherit inputs;
      name = "chest";
    })
  ];

  nix.settings.cores = 3;
  nixpkgs.config.allowBroken = true;
  programs.gamemode.enable = true;
  hardware.bluetooth.enable = true;
  host.laptop = true;
}
