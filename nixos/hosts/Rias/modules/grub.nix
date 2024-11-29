{ pkgs, ... }: let
   theme = pkgs.fetchFromGitHub {
    owner = "OliveThePuffin";
    repo = "yorha-grub-theme";
    rev = "4d9cd37baf56c4f5510cc4ff61be278f11077c81";
    hash = "sha256-XVzYDwJM7Q9DvdF4ZOqayjiYpasUeMhAWWcXtnhJ0WQ=";
   };
in {
  boot.loader.grub = {
    gfxmodeEfi = "3440x1440";
    theme = "${theme}/yorha-2560x1440";
  };
}
