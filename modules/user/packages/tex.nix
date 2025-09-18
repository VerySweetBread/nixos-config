{ pkgs, ... }: {
  home.packages = with pkgs; [
    texstudio
    (texlive.combine {
      inherit (texlive)
        babel-russian
        cm-super
        cyrillic
        hyphen-russian
        hyphenat
        titlesec
        caption
        float
        xcolor
        listings
        pagecolor
        moresize
        raleway
        fontawesome5
        luatexbase
        fontspec
        ragged2e
        enumitem
        extsizes
        multirow
        varwidth
        paracol
        anyfontsize
        scheme-basic;
    })
  ];
}
