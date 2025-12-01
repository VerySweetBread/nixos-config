{ pkgs, pkgs-pinned, host, ... }: {
  imports = [
    ../../modules/user/packages/cs_utils.nix
  ];

  disabledModules = [
    ../../modules/user/packages/art.nix
    ../../modules/user/packages/coding.nix
  ];
  home.packages = with pkgs; [
    nautilus
    python3
    pkgs-pinned.jetbrains.pycharm-community
    aseprite
    krita
    google-chrome
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = "google-chrome.desktop";
  };
}
