{ pkgs, pkgs-fixed, host, ... }: {
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
    pkgs-fixed.jetbrains.pycharm-community
    aseprite
    krita
  ];
}
