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

        "Music" = {
          path = "/home/sweetbread/Music";
          devices = [ "Akeno" "Koneko" ];
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
