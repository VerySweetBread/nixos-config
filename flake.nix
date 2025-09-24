{
  description = "My system configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      # "https://cache.garnix.io"
      "https://hyprland.cachix.org"
      "https://ezkea.cachix.org"
      "https://risdeveau.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "risdeveau.cachix.org-1:TsoFSVeLl7iKtUYGX7qsvKPjf2vbNLfLC5v3SAdU8r0="
    ];
  };

  inputs = {
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-fixed.url = "github:nixos/nixpkgs/ce01daebf8489ba97bd1609d185ea276efdeb121";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
    ags.url = "github:Aylur/ags/3ed9737bdbc8fc7a7c7ceef2165c9109f336bff6";
    yazi.url = "github:sxyazi/yazi";

    hyprland.url = "github:hyprwm/Hyprland/v0.51.1-b";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-fixed, home-manager, ... }@inputs: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      Rias = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          pkgs-unstable = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-fixed = import nixpkgs-fixed {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [ ./host/Rias/configuration.nix ];
      };

      Senko = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          pkgs-unstable = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-fixed = import nixpkgs-fixed {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [ ./host/Senko/configuration.nix ];
      };

      Eclipse = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          pkgs-unstable = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-fixed = import nixpkgs-fixed {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [ ./host/Eclipse/configuration.nix ];
      };

      Impreza = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          pkgs-unstable = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-fixed = import nixpkgs-fixed {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [ ./host/Impreza/configuration.nix ];
      };
    };

    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      shellHook = "zsh";
      packages = with pkgs; [
        cargo
        rustc
        rust-analyzer
        lldb
      ];
    };
  };
}
