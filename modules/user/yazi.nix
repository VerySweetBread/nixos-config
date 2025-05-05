{ pkgs, lib, ... }: let
	yazi-plugins = pkgs.fetchFromGitHub {
		owner = "yazi-rs";
		repo = "plugins";
		rev = "864a0210d9ba1e8eb925160c2e2a25342031d8d3";
		hash = "sha256-m3709h7/AHJAtoJ3ebDA40c77D+5dCycpecprjVqj/k=";
	};
	starship = pkgs.fetchFromGitHub {
		owner = "Rolv-Apneseth";
		repo = "starship.yazi";
		rev = "6fde3b2d9dc9a12c14588eb85cf4964e619842e6";
		sha256 = "sha256-+CSdghcIl50z0MXmFwbJ0koIkWIksm3XxYvTAwoRlDY=";
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
				{
					on = [ "g" "<S-d>" ];
					run = ''cd /mnt/D'';
					desc = "Goto D drive";
				}
			];
		};
	};
}
