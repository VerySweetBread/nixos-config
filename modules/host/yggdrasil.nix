{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Peers = [
        "tcp://lair.moe:5001"
      ];
    };
  };
}