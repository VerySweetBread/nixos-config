{ pkgs, inputs, pkgs-fixed, ... }: {
  home.packages = with pkgs; [
    google-chrome
    inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
    vesktop
    obs-studio
    mpv
    obsidian
    pkgs-fixed.thunderbird
  ];
}
