{ config, ... }: {
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.keyFile = "/home/chest/.config/sops/age/keys.txt";

    secrets."tokens/apis/wallhaven" = {};
  };
}
