{ pkgs, pkgs-pinned, inputs, ... }: {
  home.packages = with pkgs; [
    pkgs-pinned.ayugram-desktop
    vesktop
    obs-studio
    mpv
    imhex
    obsidian
    qbittorrent
    thunderbird
    libreoffice
  ];
}
