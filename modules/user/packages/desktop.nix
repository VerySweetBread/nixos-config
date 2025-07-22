{ pkgs, inputs, pkgs-fixed, ... }: {
  home.packages = with pkgs; [
    google-chrome
    ayugram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    pkgs-fixed.thunderbird
  ];
}
