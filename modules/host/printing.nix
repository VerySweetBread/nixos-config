{ config, lib, pkgs, ... }:

lib.mkIf config.services.printing.enable {
  services = {
    printing.drivers = with pkgs; [
      brlaser
    ];

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

  environment.systemPackages = with pkgs; [
    sane-frontends
    simple-scan
  ];
}
