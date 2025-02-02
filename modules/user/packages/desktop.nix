{ pkgs, pkgs-stable, inputs, ... }: {
  home.packages = with pkgs; [
    pkgs-stable.google-chrome
    inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    thunderbird
    libreoffice
  ];
}
