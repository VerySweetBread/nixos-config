{ config, pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./secrets/secrets.nix
    ./modules/grub.nix
    ./modules/aagl.nix
    ../../packages.nix
    ../../modules/bundle.nix
    ../../modules/gamemode.nix
    ../../modules/users/chest.nix
  ];

  networking.hostName = "Eclipse";

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

  networking.hosts = {
    "0.0.0.0" = [
      "overseauspider.yuanshen.com"
      "log-upload-os.hoyoverse.com"
      "log-upload-os.mihoyo.com"
      "dump.gamesafe.qq.com"

      "apm-log-upload-os.hoyoverse.com"
      "zzz-log-upload-os.hoyoverse.com"

      "log-upload.mihoyo.com"
      "devlog-upload.mihoyo.com"
      "uspider.yuanshen.com"
      "sg-public-data-api.hoyoverse.com"
      "hkrpg-log-upload-os.hoyoverse.com"
      "public-data-api.mihoyo.com"

      "prd-lender.cdp.internal.unity3d.com"
      "thind-prd-knob.data.ie.unity3d.com"
      "thind-gke-usc.prd.data.corp.unity3d.com"
      "cdp.cloud.unity3d.com"
      "remote-config-proxy-prd.uca.cloud.unity3d.com"

      "pc.crashsight.wetest.net"
    ];
  };
}

