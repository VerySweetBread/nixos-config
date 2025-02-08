{ pkgs, lib, ... }: let
	yazi-plugins = pkgs.fetchFromGitHub {
		owner = "yazi-rs";
		repo = "plugins";
		rev = "07258518f3bffe28d87977bc3e8a88e4b825291b";
		hash = "sha256-axoMrOl0pdlyRgckFi4DiS+yBKAIHDhVeZQJINh8+wk=";
	};
	starship = pkgs.fetchFromGitHub {
		owner = "Rolv-Apneseth";
		repo = "starship.yazi";
		rev = "d1cd0a38aa6a2c2e86e62a466f43e415f781031e";
		sha256 = "sha256-XiEsykudwYmwSNDO41b5layP1DqVa89e6Emv9Qf0mz0=";
	};
in {
	programs.yazi = {
		enable = true;
		enableZshIntegration = true;
		shellWrapperName = "y";

		settings = {
			manager = {
				show_hidden = true;
			};
			preview = {
				max_width = 1000;
				max_height = 1000;
			};
		};

		plugins = {
			chmod = "${yazi-plugins}/chmod.yazi";
			full-border = "${yazi-plugins}/full-border.yazi";
			max-preview = "${yazi-plugins}/max-preview.yazi";
			starship = starship;
		};

		initLua = ''
			require("full-border"):setup()
			require("starship"):setup()
		'';

		keymap = {
			manager.prepend_keymap = [
				{
					on = "T";
					run = "plugin --sync max-preview";
					desc = "Maximize or restore the preview pane";
				}
				{
					on = ["c" "m"];
					run = "plugin chmod";
					desc = "Chmod on selected files";
				}
				{
					on = [ "<C-n>" ];
					run = ''shell '${lib.getExe pkgs.xdragon} -x -i -T "$@"' --confirm'';
				}
			];
		};
	};
}
