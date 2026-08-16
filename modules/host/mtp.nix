{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.glib ];
  programs.fuse.enable = true;
  services.gvfs.enable = true;
}
