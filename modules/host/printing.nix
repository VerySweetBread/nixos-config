{ config, lib, ... }:

lib.mkIf config.services.printing.enable {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
