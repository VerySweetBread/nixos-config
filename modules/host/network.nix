{
  networking = {
    enableIPv6 = true;
    useDHCP = false;
    nameservers = [ "193.222.99.172" "1.1.1.1" ];

    dhcpcd.extraConfig = "nohook resolv.conf";

    networkmanager = {
      enable = true;
      dns = "none";
      insertNameservers = [ "193.222.99.172" "1.1.1.1" ];
    };
  };
}
