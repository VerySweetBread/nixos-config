{ config, pkgs, ... }: {
  home.packages = [ pkgs.nh ];
  programs = {
    zoxide.enable = true;
    fzf.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = true;
        format = ''
          $os$directory$git_branch$git_status
          $nix_shell$status$character
        '';
        right_format = "$all";

        cmake.disabled = true;
        cmd_duration = {
          format = "";
          show_notifications = true;
          notification_timeout = 10000;
        };
        git_branch.format = "on [$branch(:$remote_branch)]($style) ";
        git_metrics.disabled = false;
        git_status = {
          conflicted = "!";
          up_to_date = "ok";
          stashed = "S";
          modified = "M";
        };
        directory = {
          truncation_length = 3;
          fish_style_pwd_dir_length = 1;
          read_only = " RO";
        };
        nix_shell.format = "[nix-shell]($style) ";
        os.disabled = false;
        python = {
          symbol = "py ";
          python_binary = ["python3" "python"];
        };
        status.disabled = false;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases =
        let
          flakeDir = "~/nix";
        in {
        rb = "nh os switch ${flakeDir}";
        upd = "nix flake update --flake ${flakeDir}";
        upg = "sudo nixos-rebuild switch --upgrade --flake ${flakeDir}";

        hms = "nh home switch ${flakeDir}";
        rhms = ''${pkgs.bash} $(home-manager generations | fzf | awk -F '-> ' '{print $2 "/activate"}')'';  #https://github.com/nix-community/home-manager/issues/1114#issuecomment-2067785129

        conf = "$EDITOR ${flakeDir}/nixos/hosts/$(hostname)/configuration.nix";
        pkgs = "$EDITOR ${flakeDir}/nixos/packages.nix";

        ll = "ls -l";
        se = "sudoedit";
        ff = "fastfetch";
        cat = "${pkgs.lib.getExe pkgs.bat}";
        cd = "z";
        lg = "lazygit";
      };

      initContent = ''
        eval "$(zoxide init zsh)"
        eval "$(nh completions zsh)"
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      '';

      envExtra = ''
        TERM=xterm-256color
      '';

      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      oh-my-zsh.enable = true;
    };
  };
}
