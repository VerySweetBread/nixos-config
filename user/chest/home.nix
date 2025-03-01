{ pkgs, pkgs-stable, ... }: {
  disabledModules = [ ../../modules/user/packages/coding.nix ];
  home.packages = with pkgs; [
    pkgs.nautilus
    pkgs.volatility2-bin
    pkgs.burpsuite
    mimikatz
    exiftool
    droidcam
    minecraft
    prismlauncher
    python3
    pkgs-stable.jetbrains.pycharm-community
    pkgs.onlyoffice-desktopeditors
  ];
}
