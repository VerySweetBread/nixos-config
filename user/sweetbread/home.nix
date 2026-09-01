{ pkgs, ... }: {
  programs.hyprlock.enable = true;
  home.packages = with pkgs; [
    android-studio
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    })
    weechat
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = "vivaldi-stable.desktop";
  };
}
