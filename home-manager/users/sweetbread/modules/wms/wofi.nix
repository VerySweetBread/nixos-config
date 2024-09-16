{ pkgs, ... }: {
  xdg.configFile."wofi/style.css".source = pkgs.fetchurl {
    name = "style.css";
    url = "https://github.com/joao-vitor-sr/wofi-themes-collection/raw/main/themes/nord.css";
    sha256 = "sha256-rMDtE7Q0hmqd9LD+Ur/QR6cMan9ev6e9IyzpwY367c0=";
  };
}
