{ pkgs, pkgs-stable, ... }: {
  disabledModules = [ ../../modules/user/packages/coding.nix ];
  home.packages = with pkgs; [
    nautilus
    burpsuite
    exiftool
    prismlauncher
    python3
    pkgs-stable.jetbrains.pycharm-community
  ];
}
