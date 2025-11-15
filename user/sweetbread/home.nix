{ pkgs, ... }: {
  imports = [
    ../../modules/user/packages/tex.nix
  ];
  programs.hyprlock.enable = true;
  home.packages = with pkgs; [
    vivaldi
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = "vivaldi-stable.desktop";
  };
}
