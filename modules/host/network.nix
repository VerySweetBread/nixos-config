{
  networking = {
    enableIPv6 = true;
    useDHCP = false;
    nameservers = [ "64.188.64.176" "1.1.1.1" ];

    dhcpcd.extraConfig = "nohook resolv.conf";

    networkmanager = {
      enable = true;
      dns = "none";
      insertNameservers = [ "64.188.64.176" "1.1.1.1" ];
    };
  };
}
