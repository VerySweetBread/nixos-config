{ config, lib, ... }: let
  inherit (lib) mkOption types;

  base16Names = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
in {
  options.stylix.accent = mkOption {
    type = types.enum base16Names;
    default = "base0B";
    description = ''
      Base16 colour used as the user accent.

      Use it as:

        config.lib.stylix.colors.${config.stylix.accent}
        config.lib.stylix.colors.withHashtag.${config.stylix.accent}

      This module deliberately does not extend config.lib.stylix.colors: Stylix
      exports that value as a generated base16 attrset/functor, and replacing or
      partially extending it can break Stylix targets which expect metadata such
      as `scheme` to be present.
    '';
  };
}
