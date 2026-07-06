{ pkgs, ... }:{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
    i2c-tools
    pciutils
  ];

  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  users.groups.i2c.members = [ "sweetbread" ];
}