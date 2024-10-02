{ pkgs, ... }: {
  home.packages = with pkgs; [
    google-chrome
    telegram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    thunderbird
  ];
}
