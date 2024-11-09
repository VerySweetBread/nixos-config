{
  description = "My system configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
    ags.url = "github:Aylur/ags";
    ayugram-desktop.url = "github:/ayugram-port/ayugram-desktop/release?submodules=1";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:

    let
      system = "x86_64-linux";
    in {

    nixosConfigurations = {
      Rias = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [
          ./nixos/hosts/Rias/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      Senko = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [
          ./nixos/hosts/Senko/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      Eclipse = nixpkgs.lib.nixosSystem {
        specialArgs = {
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          inherit inputs system;
        };
        modules = [
          ./nixos/hosts/Eclipse/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };
    };

    homeConfigurations = {
      sweetbread = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./home-manager/users/sweetbread/home.nix
          inputs.sops-nix.homeManagerModules.sops
          inputs.stylix.homeManagerModules.stylix
          inputs.ags.homeManagerModules.default
        ];
      };
      
      chest = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./home-manager/users/chest/home.nix
          inputs.sops-nix.homeManagerModules.sops
          inputs.stylix.homeManagerModules.stylix
          inputs.ags.homeManagerModules.default
        ];
      };
    };
  };
}
