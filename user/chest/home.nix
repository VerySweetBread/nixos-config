{ pkgs, pkgs-fixed, ... }: {
  disabledModules = [ ../../modules/user/packages/coding.nix ];
  home.packages = with pkgs; [
    nautilus
    burpsuite
    exiftool
    python3
    pkgs-fixed.jetbrains.pycharm-community
  ];
}
