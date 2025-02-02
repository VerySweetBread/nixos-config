{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      # theme = "catppuccin-mocha";
      editor = {
        insert-final-newline = false;
        whitespace.render = {
          space = "all";
          tab = "all";
          nbsp = "none";
          nnbsp = "none";
          newline = "none";
        };

        indent-guides.render = true;
      };
    };
  };
}
