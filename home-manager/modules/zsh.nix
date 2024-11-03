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
          $status$character
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
        os.disabled = false;
        python = {
          symbol = "py ";
          python_binary = ["python3" "python"];
        };
        status.disabled = false;
      };
    };

    zellij.enable = true;

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

        conf = "$EDITOR ${flakeDir}/nixos/hosts/$(hostname)/configuration.nix";
        pkgs = "$EDITOR ${flakeDir}/nixos/packages.nix";

        ll = "ls -l";
        se = "sudoedit";
        ff = "fastfetch";
        cat = "bat";
        cd = "z";
      };

      initExtra = ''
        eval "$(zoxide init zsh)"
        eval "$(nh completions --shell zsh)"
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      '';

      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      oh-my-zsh.enable = true;
    };
  };
}
