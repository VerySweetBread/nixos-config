{ pkgs, inputs, pkgs-fixed, ... }: {
  home.packages = with pkgs; [
    ayugram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    pkgs-fixed.thunderbird
  ];
}
