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
        Akeno = { id = "QDW3WJX-J7ETS4R-32CUAIY-EGNM2RD-ZEHOUW2-CHOEOUG-USZOWTR-HHQS2QX"; };
        Koneko = { id = "PJFWQRY-ZFUBGDR-NV7KVBL-UBDQ4HT-KPTYP34-MUDFPJU-4EZUHTT-ZLYRMAB"; };
      };

      folders = {
        "Books" = {
          path = "/mnt/D/SyncThing/Books";
          devices = [ "Akeno" "Koneko" ];
        };

        ".RPI" = {
          path = "/mnt/D/SyncThing/.RPI";
          devices = [ "Akeno" "Koneko" ];
        };

        "JoiPlay" = {
          path = "/mnt/D/SyncThing/JoiPlay";
          devices = [ "Akeno" ];
        };

        "Music" = {
          path = "/home/sweetbread/Music";
          devices = [ "Akeno" "Koneko" ];
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
