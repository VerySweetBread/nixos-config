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
        Akeno.id = "QDW3WJX-J7ETS4R-32CUAIY-EGNM2RD-ZEHOUW2-CHOEOUG-USZOWTR-HHQS2QX";
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
