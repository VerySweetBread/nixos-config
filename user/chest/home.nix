{ pkgs, pkgs-stable, ... }: {
  disabledModules = [ ../../modules/user/packages/coding.nix ];
  home.packages = with pkgs; [
    nautilus
    burpsuite
    exiftool
    python3
    pkgs-stable.jetbrains.pycharm-community
  ];
}
