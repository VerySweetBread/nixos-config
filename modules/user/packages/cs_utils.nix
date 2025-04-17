{ pkgs, ... }: {
  home.packages = with pkgs; [
    burpsuite
    binwalk
    exiftool
  ];
}
