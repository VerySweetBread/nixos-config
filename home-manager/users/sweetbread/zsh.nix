{ config, pkgs, ... }: {
  home.packages = [ pkgs.nh ];
  programs.zoxide.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableAutosuggestions = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "~/nix";
      in {
      rb = "nh os switch ${flakeDir}";
      upd = "nix flake update ${flakeDir}";
      upg = "sudo nixos-rebuild switch --upgrade --flake ${flakeDir}";

      hms = "nh home switch ${flakeDir}";

      conf = "$EDITOR ${flakeDir}/nixos/hosts/$(hostname)/configuration.nix";
      pkgs = "$EDITOR ${flakeDir}/nixos/packages.nix";

      ll = "ls -l";
      se = "sudoedit";
      ff = "fastfetch";
      cat = "bat";
      cd = "z";
    };

    initExtra = ''
      if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        dbus-run-session Hyprland
      fi
      eval "$(zoxide init zsh)"
      eval "$(nh completions --shell zsh)"
    '';

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "agnoster"; # blinks is also really nice
    };
  };
}
