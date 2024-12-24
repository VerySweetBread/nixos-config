{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    scrot
    ffmpeg
    yt-dlp
    bat
    fd
    feh
    imv
    gromit-mpx
    notify-desktop
    rtorrent
    inputs.tlock.packages.${system}.default
  ];
}
