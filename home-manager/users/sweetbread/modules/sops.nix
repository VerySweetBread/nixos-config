{ config, ... }: {
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.keyFile = "/home/sweetbread/.config/sops/age/keys.txt";

    secrets."tokens/apis/wallhaven" = {};
  };
}
