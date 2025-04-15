{ pkgs, pkgs-fixed, host, ... }: {
  disabledModules = [ ../../modules/user/packages/coding.nix ];
  home.packages = with pkgs; [
    nautilus
    burpsuite
    binwalk
    exiftool
    python3
    pkgs-fixed.jetbrains.pycharm-community
  ];
}
