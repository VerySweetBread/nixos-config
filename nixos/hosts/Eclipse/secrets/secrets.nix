{
  sops = {
    age.keyFile = "/root/age.key";
    secrets.vpn_bolt = {
      format = "binary";
      sopsFile = ./vpn_bolt.db;
    };
  };
}
