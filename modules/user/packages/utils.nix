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
    gparted
    git-lfs
    unrar
    hexyl
    jq
    litecli
    trashy
    dig
    mtr
    imagemagick
  ];
}
