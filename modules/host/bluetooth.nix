{ config, lib, ... }: {
  hardware.bluetooth =
  lib.mkIf config.hardware.bluetooth.enable {
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;
}
