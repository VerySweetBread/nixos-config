{ pkgs, pkgs-stable, ... }: {
  disabledModules = [ ../../modules/user/packages/coding.nix ];
  home.packages = [
    pkgs.nautilus
    pkgs-stable.jetbrains.pycharm-community
  ];
}
