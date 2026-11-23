{ pkgs, lib, osConfig, ... }: let
  # Match the Electron FFmpeg build recommended by Vivaldi 8.2.
  vivaldiCodecs = pkgs.runCommand "vivaldi-ffmpeg-electron-44.4.2" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p "$out/lib"
    unzip -p ${pkgs.fetchurl {
      url = "https://github.com/electron/electron/releases/download/v44.4.2/electron-v44.4.2-linux-x64.zip";
      hash = "sha256-rXEGPnfaKaZH+HKwkEePn6nM/9Z957KuYxVAnPHxNDY=";
    }} libffmpeg.so > "$out/lib/libffmpeg.so"
    echo "39f63af3ef6f8db9eea20803c6f6dff8b2d5ad596d506ea1effb3f856715ac1c  $out/lib/libffmpeg.so" | sha256sum -c
  '';
in {
  imports = [
    ../../modules/user/lucid
    ./modules/lucid
  ] ++ lib.optionals (osConfig.networking.hostName == "Rias") [
    ../../host/Rias/modules/lucid
    ./modules/lucid/rias.nix
  ] ++ lib.optionals (osConfig.networking.hostName == "Inaho") [
    ../../host/Inaho/modules/lucid
    ./modules/lucid/rias.nix
  ];

  programs.hyprlock.enable = true;
  home.packages = with pkgs; [
    android-studio
    (vivaldi.override {
      proprietaryCodecs = true;
      vivaldi-ffmpeg-codecs = vivaldiCodecs;
      enableWidevine = true;
    })
    weechat
    insomnia
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = "vivaldi-stable.desktop";
  };
}
