{ pkgs, ... }: {
  xdg.configFile."wofi/style.css".source = pkgs.requireFile {
  xdg.configFile."wofi/style.css".source = pkgs.fetchurl {
    name = "style.css";
    url = "https://raw.githubusercontent.com/PaulGuerre/arch_dotfiles/main/wofi/style.css";
    sha256 = "16lr4j0nn6kpggr4wdz9s0jymqmn05vm7i4vsdslzp5vlarcv03j";
  };
}
