{
  description = "My system configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix.codrs.ru/main"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "main:kpwMe+9BsGJ/IUb7i3iadaV38y5/Yuqoct0mf7wI9ds="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
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

    hyprland.url = "github:hyprwm/Hyprland/v0.52.1-b";
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
    config = { allowUnfree = true; };
    mkHost = hostname: nixpkgs-stable.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        pkgs-unstable = import nixpkgs { inherit system config; };
        pkgs-fixed = import nixpkgs-fixed { inherit system config; };
      };
      modules = [ ./host/${hostname}/configuration.nix ];
    };
  in {
    nixosConfigurations = {
      Rias = mkHost "Rias";
      Senko = mkHost "Senko";
      Eclipse = mkHost "Eclipse";
      Impreza = mkHost "Impreza";
    };
  };
}
