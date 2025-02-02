{ lib, inputs, hostname }: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../${hostname}/hardware-configuration.nix
    ../../modules/host.nix
    ./packages.nix
  ];

  options = {
    host.laptop = lib.mkEnableOption "laptop mode";
  };

  config = {
    networking.hostName = hostname;
    time.timeZone = lib.mkDefault "Europe/Moscow";
    i18n.defaultLocale = lib.mkDefault "ru_RU.UTF-8";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "23.05";
  };
}