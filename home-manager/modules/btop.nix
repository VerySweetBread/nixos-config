{ pkgs, ... }: {
  programs.btop = {
    enable = true;
    package = pkgs.btop.override { cudaSupport = true; };
    settings = {
      shown_boxes = "proc cpu gpu0 mem net";
      # color_theme = "TTY";
      update_ms = 1000;
      cpu_single_graph = true;
      only_physical = false;
      net_auto = false;
      net_iface = "eno1";
    };
  };
}
