{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Peers = [
        "tcp://box.paulll.cc:13337"
        "tcp://lair.moe:5001"
      ];
    };
  };
}