{ config, ... }: {
  sops = {
    defaultSopsFile = ../../user/${config.home.username}/secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets."tokens/apis/wallhaven" = {};
  };
}
