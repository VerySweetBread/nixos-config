{ pkgs, ... }: {
  xdg.configFile.nvim = {
    source = pkgs.fetchFromGitHub {
      owner = "AstroNvim";
      repo = "template";
      rev = "60a8ea905787c27cbd854985e47dc2195e763732";
      sha256 = "03bxdzs9zjm1xd0aqwsckm1d2hbz8bsfw6ac5fzx319a2hyiwfp9";
    };
    recursive = true;
  };
}
