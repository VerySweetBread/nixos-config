{ pkgs, inputs, pkgs-fixed, ... }: {
  home.packages = with pkgs; [
    google-chrome
    inputs.ayugram-desktop.packages.${pkgs.system}.ayugram-desktop
    # pkgs-stable.vesktop
    vesktop
    obs-studio
    mpv
    obsidian
    pkgs-fixed.thunderbird
  ];
}
