{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        width = 40;
        line-height = 25;
        fields = "name,generic,comment,categories,filename,keywords";
        prompt = ''"❯   "'';
        show-actions = "no";
        filter-desktop = "yes";
        match-counter = "yes";
      };

      border = {
        radius = "20";
      };

      dmenu = {
        exit-immediately-if-empty = "yes";
      };
    };
  };
}