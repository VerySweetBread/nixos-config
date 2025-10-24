{ pkgs, inputs, pkgs-fixed, ... }: {
  home.packages = with pkgs; [
    ayugram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    qbittorrent
    pkgs-fixed.thunderbird
  ];
}
