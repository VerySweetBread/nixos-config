{ pkgs, pkgs-stable, ... }: {
  home.packages = with pkgs; [
    ayugram-desktop
    vesktop
    obs-studio
    mpv
    imhex
    obsidian
    pkgs-stable.qbittorrent
    thunderbird
    libreoffice
    pear-desktop
    ( pkgs.callPackage ../../../drv/mumble.nix {} )
  ];
}
