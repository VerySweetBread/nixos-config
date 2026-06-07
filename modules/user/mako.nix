{ config, lib, ... }: let
  colors = config.lib.stylix.colors.withHashtag;
  accent = colors.${config.stylix.accent};
in {
  services.mako = {
    enable = true;

    settings = {
      border-color = lib.mkForce accent;
      default-timeout = 5000;
    };
  };
}
