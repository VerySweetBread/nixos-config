{ config, ... }: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    user = "sweetbread";
    dataDir = "/home/sweetbread/.config/syncthing";

    key = config.sops.secrets.syncthing_key.path;
    cert = config.sops.secrets.syncthing_cert.path;

    settings = {
      devices = {
        Akeno = { id = "YVFVE2M-GSCKJBJ-AMC5JM3-AOMCVNP-RLFAWEZ-35VP4HP-DGP5QD2-6QWEZQW"; };
      };

      folders = {
        "Books" = {
          path = "/mnt/D/SyncThing/Books";
          devices = [ "Akeno" ];
        };

        ".RPI" = {
          path = "/mnt/D/SyncThing/.RPI";
          devices = [ "Akeno" ];
        };

        "Music" = {
          path = "/home/sweetbread/Music";
          devices = [ "Akeno" ];
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
