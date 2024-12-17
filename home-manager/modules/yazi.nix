{ pkgs, lib, ... }: let
	yazi-plugins = pkgs.fetchFromGitHub {
		owner = "yazi-rs";
		repo = "plugins";
		rev = "7afba3a73cdd69f346408b77ea5aac26fe09e551";
		hash = "sha256-w9dSXW0NpgMOTnBlL/tzlNSCyRpZNT4XIcWZW5NlIUQ=";
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
			starship = pkgs.fetchFromGitHub {
				owner = "Rolv-Apneseth";
				repo = "starship.yazi";
				rev = "247f49da1c408235202848c0897289ed51b69343";
				sha256 = "sha256-0J6hxcdDX9b63adVlNVWysRR5htwAtP5WhIJ2AK2+Gs=";
			};
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
			];
		};
	};
}
