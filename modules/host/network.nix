{
  networking = {
    enableIPv6 = true;
    useDHCP = false;
    nameservers = [ "185.246.223.236" "1.1.1.1" ];

    dhcpcd.extraConfig = "nohook resolv.conf";

    networkmanager = {
      enable = true;
      dns = "none";
      insertNameservers = [ "185.246.223.236" "1.1.1.1" ];
    };
  };
}
