{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        serverAliveInterval = 30;
        serverAliveCountMax = 5;
      };
    };
  };
}
