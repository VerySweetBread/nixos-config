{

  imports = [
    ./zsh.nix
    ./modules/bundle.nix
  ];

  home = {
    username = "chest";
    homeDirectory = "/home/chest";
    stateVersion = "23.11";
  };
}
