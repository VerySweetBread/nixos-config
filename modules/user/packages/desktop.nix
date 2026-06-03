{ pkgs, ... }: {
  home.packages = with pkgs; [
    ayugram-desktop
    vesktop
    obs-studio
    mpv
    imhex
    obsidian
    qbittorrent
    thunderbird
    libreoffice
    pear-desktop
  ];
}
