{ pkgs, pkgs-pinned, host, ... }: {
  imports = [
    ../../modules/user/packages/cs_utils.nix
  ];
  disabledModules = [
    ../../modules/user/packages/art.nix
  ];

  home.packages = with pkgs; [
    nautilus
    vscode
    python3
    python3Packages.pip
    pkgs-pinned.jetbrains.pycharm-oss
    aseprite
    krita
    google-chrome
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = "google-chrome.desktop";
  };
}
