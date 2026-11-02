{ pkgs, lib, osConfig, ... }: {
  imports = [
    ../../modules/user/lucid
    ./modules/lucid
  ] ++ lib.optionals (osConfig.networking.hostName == "Rias") [
    ../../host/Rias/modules/lucid
    ./modules/lucid/rias.nix
  ];

  programs.hyprlock.enable = true;
  home.packages = with pkgs; [
    android-studio
    (vivaldi.override {
      proprietaryCodecs = true;
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
