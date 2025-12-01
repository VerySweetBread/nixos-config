{ config, pkgs, pkgs-stable, pkgs-pinned, lib, inputs, ... }: {
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
      inherit pkgs-pinned;
      inherit lib;
      inherit inputs;
      name = "chest";
    })
  ];

  nixpkgs.config.allowBroken = true;
  programs.gamemode.enable = true;
  services.printing.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "chest" ];
}
