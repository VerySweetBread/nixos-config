{ pkgs, pkgs-stable, lib, inputs, name, fullname ? name, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${name} = {
          imports = [
            inputs.sops-nix.homeManagerModules.sops
            inputs.stylix.homeManagerModules.stylix
            ../modules/user.nix
            ./${name}/modules/git.nix
            ./${name}/modules/hyprland.nix
            ./${name}/modules/style.nix
            ./${name}/home.nix
          ];

          home = {
            username = name;
            homeDirectory = "/home/${name}";
            stateVersion = "23.11";
          };
        };
        extraSpecialArgs = {
          inherit inputs;
          inherit pkgs-stable;
        };
      };
    }
  ];

  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users."${name}" = {
      isNormalUser = true;
      description = fullname;
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" ];
    };
  };

  services.greetd = let
    tuigreet = lib.getExe pkgs.greetd.tuigreet;
    session = lib.getExe inputs.hyprland.packages.${pkgs.system}.default;
  in {
    enable = true;
    settings = {
      initial_session = {
        command = "${session}";
        user = "${name}";
      };
      default_session = {
        command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}";
        user = "greeter";
      };
    };
  };

  nix.settings.trusted-users = [ name ];
}
