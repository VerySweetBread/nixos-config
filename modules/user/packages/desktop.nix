{ pkgs, inputs, pkgs-stable, ... }: {
  home.packages = with pkgs; [
    google-chrome
    inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
    pkgs-stable.vesktop
    obs-studio
    mpv
    obsidian
    thunderbird
    libreoffice
  ];
}
