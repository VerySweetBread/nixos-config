{ config, pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../packages.nix
    ../../modules/bundle.nix
    ../../modules/adb.nix
    ../../modules/users/sweetbread.nix
    ../../modules/laptop.nix
  ];

  networking.hostName = "Senko";

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver intel-media-driver];
    extraPackages32 = with pkgs.pkgsi686Linux; [nvidia-vaapi-driver intel-media-driver];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
