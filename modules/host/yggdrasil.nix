{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Peers = [
        "tcp://codrs.ru:5001"
      ];
    };
  };
}