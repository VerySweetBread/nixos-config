{ pkgs, ... }: {
  home.packages = with pkgs; [
    texstudio
    (texlive.combine {
      inherit (texlive)
        babel-russian
        cm-super
        cyrillic
        titlesec
        hyperref
        geometry
        caption
        float
        xcolor
        listings
        scheme-basic;
    })
  ];
}
