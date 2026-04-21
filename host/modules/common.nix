{ lib, inputs, hostname }: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../${hostname}/hardware-configuration.nix
    ../../modules/host.nix
    ./packages.nix
  ];

  options = {
    host = {
      laptop = lib.mkEnableOption "laptop mode";

      nvidia.prime = {
        enable = lib.mkEnableOption "NVIDIA PRIME offload for hybrid graphics";
        intelBusId = lib.mkOption {
          type = lib.types.str;
          default = "PCI:0:2:0";
          description = "Intel/iGPU Bus ID used by NVIDIA PRIME.";
        };
        nvidiaBusId = lib.mkOption {
          type = lib.types.str;
          default = "PCI:1:0:0";
          description = "NVIDIA dGPU Bus ID used by NVIDIA PRIME.";
        };
      };
    };
  };

  config = {
    nix.settings = {
      keep-going = true;
      extra-substituters = [ "https://nix.lair.moe/main" ];
      extra-trusted-public-keys = [ "main:kpwMe+9BsGJ/IUb7i3iadaV38y5/Yuqoct0mf7wI9ds=" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    networking.hostName = hostname;
    time.timeZone = lib.mkDefault "Europe/Moscow";
    i18n.defaultLocale = lib.mkDefault "ru_RU.UTF-8";
    system.stateVersion = "23.05";
  };
}
