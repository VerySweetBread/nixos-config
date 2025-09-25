{ pkgs, pkgs-unstable, config, ...}: {
  systemd.services.v2raya = {
    enable = true;
    description = "v2rayA gui client";
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs-unstable.v2raya}/bin/v2rayA";
    };
    path = with pkgs; [ iptables bash iproute2 ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      V2RAYA_LOG_FILE = "/var/log/v2raya/v2raya.log";
      V2RAY_LOCATION_ASSET = "/etc/v2raya";
      XRAY_LOCATION_ASSET = "/etc/v2raya";
    };
  };

  environment.etc = {
    "v2raya/ru_geoip.dat".source = pkgs.fetchurl {
      name = "geoip.dat";
      url = "https://github.com/runetfreedom/russia-blocked-geoip/releases/download/202509251525/geoip.dat";
      hash = "sha256-bhz32BOLoqq8yYe8tXWQRkqUiDMa4jAuhLjDfcyF9d4=";
    };

    "v2raya/bolt.db".source = config.sops.secrets.vpn_bolt.path;
  };
}
