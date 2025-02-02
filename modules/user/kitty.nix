{ lib, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = lib.mkDefault {
      dynamic_background_opacity = "yes";
      background_opacity = 0.5;
      background_blur = true;
      background = "#1d2021";
      font_size = 13.0;
      cursor_blink_interval = "0.5 ease-in-out";
    };
  };
  programs.zsh.envExtra = "TERM=xterm-256color";
}
