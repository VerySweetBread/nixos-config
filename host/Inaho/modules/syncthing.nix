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
        Rias.id = "EC5AGVN-2RKJDHN-NOSB7PQ-IRYCEEW-NPPDUGX-6QGSLUU-YIT5ZZZ-RVPTHQ6";
        Akeno.id = "QDW3WJX-J7ETS4R-32CUAIY-EGNM2RD-ZEHOUW2-CHOEOUG-USZOWTR-HHQS2QX";
        Koneko.id = "PJFWQRY-ZFUBGDR-NV7KVBL-UBDQ4HT-KPTYP34-MUDFPJU-4EZUHTT-ZLYRMAB";
      };

      folders = {
        "Music" = {
          path = "/home/sweetbread/Music";
          devices = [ "Rias" "Akeno" "Koneko" ];
        };

        "Obsidian" = {
          path = "/home/sweetbread/Documents/Obsidian";
          devices = [ "Rias" "Akeno" "Koneko" ];
        };

        "Documents" = {
          path = "/home/sweetbread/Documents";
          devices = [ "Rias" ];
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
