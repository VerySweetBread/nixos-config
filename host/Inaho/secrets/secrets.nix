{
  sops = {
    age.keyFile = "/root/age.key";
    secrets = {
      vpn_bolt = {
        format = "binary";
        sopsFile = ../../Rias/secrets/vpn_bolt.db;
      };

      syncthing_cert = {
        format = "binary";
        sopsFile = ./syncthing_cert.pem;
      };
      syncthing_key = {
        format = "binary";
        sopsFile = ./syncthing_key.pem;
      };
    };
  };
}
