{ inputs, ... }: {
  imports = [ inputs.kaizen.homeManagerModules.default ];
  programs.kaizen.enable = true;
}
