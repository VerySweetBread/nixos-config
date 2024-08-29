{ pkgs, ... }: {
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;

    users.sweetbread = {
      isNormalUser = true;
      description = "Sweet Bread";
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" ];
      packages = with pkgs; [];
    };
  };

  services.getty.autologinUser = "sweetbread";
}
