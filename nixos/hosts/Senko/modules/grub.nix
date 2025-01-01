{ pkgs, ... }: let
   theme = pkgs.fetchFromGitHub {
    owner = "Patato777";
    repo = "dotfiles";
    rev = "cc363921707807d7ad3e36b462f0df793a0fe18a";
    hash = "sha256-fpXGFNrzbV6K9hoZRX4tGieTLzhpPeGm6wn8CF4OGow=";
   };
in {
  boot.loader.grub = {
    gfxmodeEfi = "1920x1080";
    theme = "${theme}/grub/themes/virtuaverse";
  };
}
