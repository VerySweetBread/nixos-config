{ lib, ... }: {
  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
  };

  systemd.services.clash-verge.serviceConfig = {
    CapabilityBoundingSet = lib.mkForce [
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
      "CAP_SYS_ADMIN"
      "CAP_DAC_OVERRIDE"
      "CAP_DAC_READ_SEARCH"
      "CAP_SYS_PTRACE"
      "CAP_SETUID"
      "CAP_SETGID"
      "CAP_CHOWN"
      "CAP_MKNOD"
    ];

    AmbientCapabilities = [
      "CAP_DAC_READ_SEARCH"
      "CAP_SYS_PTRACE"
    ];
  };
}
