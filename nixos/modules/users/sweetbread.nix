{ pkgs, lib, inputs, ... }: {
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

  services.greetd = let
    tuigreet = pkgs.lib.getExe pkgs.greetd.tuigreet;
    session = lib.getExe inputs.hyprland.packages.${pkgs.system}.default;
    username = "sweetbread";
  in {
    enable = true;
    settings = {
      initial_session = {
        command = "${session}";
        user = "${username}";
      };
      default_session = {
        command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${session}";
        user = "greeter";
      };
    };
  };

  nix.settings.trusted-users = [ "sweetbread" ];
}
