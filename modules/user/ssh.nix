{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        serverAliveInterval = 30;
        serverAliveCountMax = 5;
      };
    };
  };
}
