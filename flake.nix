{
  description = "My system configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix.lair.moe/main"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://ezkea.cachix.org"
      "https://yazi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "main:tR2gNhCBJHKAlVgohPNHBhGnWL55tB8SxXmMWJe5lo8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };

  inputs = {
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-pinned.url = "github:nixos/nixpkgs/ec942ba042dad5ef097e2ef3a3effc034241f011";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
    ags.url = "github:Aylur/ags/3ed9737bdbc8fc7a7c7ceef2165c9109f336bff6";

    helix-steel = {
      url = "github:mattwparas/helix/steel-event-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };

    hyprland.url = "github:hyprwm/Hyprland/v0.56.1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-pinned, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        pkgs-stable = import nixpkgs-stable { inherit system config; };
        pkgs-pinned = import nixpkgs-pinned { inherit system config; };
      };
      modules = [ ./host/${hostname}/configuration.nix ];
    };
  in {
    nixosConfigurations = {
      Rias = mkHost "Rias";
      Senko = mkHost "Senko";
      Eclipse = mkHost "Eclipse";
      Impreza = mkHost "Impreza";
      Inaho = mkHost "Inaho";
    };
  };
}
