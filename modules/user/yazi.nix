{ pkgs, lib, ... }: let
	yazi-plugins = pkgs.fetchFromGitHub {
		owner = "yazi-rs";
		repo = "plugins";
		rev = "273019910c1111a388dd20e057606016f4bd0d17";
		hash = "sha256-80mR86UWgD11XuzpVNn56fmGRkvj0af2cFaZkU8M31I=";
	};
	starship = pkgs.fetchFromGitHub {
		owner = "Rolv-Apneseth";
		repo = "starship.yazi";
		rev = "6c639b474aabb17f5fecce18a4c97bf90b016512";
		sha256 = "sha256-bhLUziCDnF4QDCyysRn7Az35RAy8ibZIVUzoPgyEO1A=";
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
