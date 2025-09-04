{ pkgs, ... }: {
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
    wl-clipboard
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/bmp"                = "imv.desktop";
      "image/gif"                = "imv.desktop";
      "image/jpeg"               = "imv.desktop";
      "image/jpg"                = "imv.desktop";
      "image/pjpeg"              = "imv.desktop";
      "image/png"                = "imv.desktop";
      "image/tiff"               = "imv.desktop";
      "image/x-bmp"              = "imv.desktop";
      "image/x-pcx"              = "imv.desktop";
      "image/x-png"              = "imv.desktop";
      "image/x-portable-anymap"  = "imv.desktop";
      "image/x-portable-bitmap"  = "imv.desktop";
      "image/x-portable-graymap" = "imv.desktop";
      "image/x-portable-pixmap"  = "imv.desktop";
      "image/x-tga"              = "imv.desktop";
      "image/x-xbitmap"          = "imv.desktop";
      "image/heif"               = "imv.desktop";
      "image/avif"               = "imv.desktop";
    };
  };
}
