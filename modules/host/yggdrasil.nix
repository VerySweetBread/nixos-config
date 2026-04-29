{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Peers = [
        "tls://ip4.01.ekb.ru.dioni.su:9003"
      ];
    };
  };
}