{
  sops = {
    age.keyFile = "/root/age.key";
    secrets = {
      vpn_bolt = {
        format = "binary";
        sopsFile = ../../Rias/secrets/vpn_bolt.db;
      };
    };
  };
}
