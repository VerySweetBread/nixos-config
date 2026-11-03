{ pkgs, lib, osConfig, ... }: {
  imports = [ ./modules/lucid.nix ]
    ++ lib.optional (osConfig.networking.hostName != "Rias") ../../modules/user/wob.nix;

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
