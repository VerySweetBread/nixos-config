{ pkgs, inputs, pkgs-fixed, ... }: {
  home.packages = with pkgs; [
    pkgs-fixed.ayugram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    qbittorrent
    thunderbird
    libreoffice
  ];
}
