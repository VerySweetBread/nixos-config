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
    nix.settings = {
      keep-going = true;
      extra-substituters = [ "https://nix.codrs.ru/main" ];
      extra-trusted-public-keys = [ "main:kpwMe+9BsGJ/IUb7i3iadaV38y5/Yuqoct0mf7wI9ds=" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    networking.hostName = hostname;
    time.timeZone = lib.mkDefault "Europe/Moscow";
    i18n.defaultLocale = lib.mkDefault "ru_RU.UTF-8";
    system.stateVersion = "23.05";
  };
}