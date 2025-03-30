{
  description = "My system configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://hyprland.cachix.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  inputs = {
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    nixpkgs.url = "github:nixos/nixpkgs/30b27177a006d425120fb850a64ceb792636501a";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-fixed.url = "github:nixos/nixpkgs/b27ba4eb322d9d2bf2dc9ada9fd59442f50c8d7c";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
    ags.url = "github:Aylur/ags";
    ayugram-desktop.url = "github:/ayugram-port/ayugram-desktop/release?submodules=1";

    hyprland.url = "github:hyprwm/Hyprland";
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
      Rias = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
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

      Senko = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
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

      Eclipse = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
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
