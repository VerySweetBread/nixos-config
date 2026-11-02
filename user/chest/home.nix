{ pkgs, pkgs-pinned, lib, osConfig, ... }: {
  imports = [
    ../../modules/user/packages/cs_utils.nix
    ../../modules/user/lucid
    ./modules/lucid
  ] ++ lib.optionals (osConfig.networking.hostName == "Impreza") [
    ../../host/Impreza/modules/lucid
  ] ++ lib.optionals (osConfig.networking.hostName == "Rias") [
    ../../host/Rias/modules/lucid
  ] ++ lib.optionals (osConfig.networking.hostName == "Eclipse") [
    ../../host/Eclipse/modules/lucid
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
