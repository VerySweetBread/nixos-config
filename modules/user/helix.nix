{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      # theme = "catppuccin-mocha";
      editor = {
        rulers = [ 81 ];
        insert-final-newline = false;
        indent-guides.render = true;

        whitespace.render = {
          space = "all";
          tab = "all";
          nbsp = "none";
          nnbsp = "none";
          newline = "none";
        };

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
  };
}
