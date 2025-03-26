{ stdenv, lib, config, colors, ... }:
  stdenv.mkDerivation {
    name = "AGS theme";

    src = ./ags;
    dontUnpack = true;

    patchPhase = ''
      echo \$bg:       \#${colors.base00}\;  > colors.scss
      echo \$surface0: \#${colors.base02}\; >> colors.scss
      echo \$fg:       \#${colors.base05}\; >> colors.scss
      echo \$accent:   \#${colors.base0B}\; >> colors.scss

      echo \#${colors.base0B} > accent.css
    '';

    installPhase = ''
      ls
      mkdir $out
      cp $src/* $out -r
      mv colors.scss $out
      mv accent.css  $out
    '';
  }
