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
}
