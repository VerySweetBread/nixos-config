{ pkgs, ... }: {
  programs.hyprlock.enable = true;
  home.packages = with pkgs; [
    libreoffice
  ];
}
