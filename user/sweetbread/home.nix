{ pkgs, ... }: {
  imports = [
    ../../modules/user/packages/tex.nix
  ];
  programs.hyprlock.enable = true;
  home.packages = with pkgs; [
    libreoffice
  ];
}
