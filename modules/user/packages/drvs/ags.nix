{ stdenv, colors, accent ? colors.base0B, ... }:
  stdenv.mkDerivation {
    name = "AGS theme";

    src = ./ags;
    dontUnpack = true;

    patchPhase = ''
      echo \$bg:       \#${colors.base00}\;  > colors.scss
      echo \$surface0: \#${colors.base02}\; >> colors.scss
      echo \$fg:       \#${colors.base05}\; >> colors.scss
      echo \$accent:   \#${accent}\; >> colors.scss

      echo \#${accent} > accent.css
    '';

    installPhase = ''
      ls
      mkdir $out
      cp $src/* $out -r
      mv colors.scss $out
      mv accent.css  $out
    '';
  }
