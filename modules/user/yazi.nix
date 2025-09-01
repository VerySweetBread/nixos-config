{ pkgs, lib, inputs, ... }: {
	home.packages = with pkgs; [
		( ouch.override { enableUnfree = true; } )
	];

	programs.yazi = {
		package = inputs.yazi.packages
			.${pkgs.stdenv.hostPlatform.system}.default
			.override { _7zz = pkgs._7zz-rar; };
		enable = true;
		enableZshIntegration = true;
		shellWrapperName = "y";

		settings = {
			mgr = {
				show_hidden = true;
			};
			preview = {
				max_width = 1000;
				max_height = 1000;
			};
			plugin = {
				preloaders = [
					{ name = "*.crdownload"; run = "noop"; }
				];

				prepend_previewers = [
					{ mime = "application/xz";            run = "ouch"; }
					{ mime = "application/zip";           run = "ouch"; }
					{ mime = "application/rar";           run = "ouch"; }
					{ mime = "application/gzip";          run = "ouch"; }
					{ mime = "application/7z-compressed"; run = "ouch"; }
				];

				prepend_fetchers = [
					{ id = "git"; mime = "*"; run = "git"; }
				];
			};
		};

		plugins = with pkgs.yaziPlugins; {
			inherit
				chmod
				ouch
				full-border
				starship
				mount
				git
				toggle-pane
				;
		};

		initLua = ''
			require("git"):setup()
			require("full-border"):setup()
			require("starship"):setup()
		'';

		keymap = {
			mgr.prepend_keymap = [
				{
					on = "T";
					run = "plugin toggle-pane max-preview";
					desc = "Maximize or restore the preview pane";
				}
				{
					on = ["c" "m"];
					run = "plugin chmod";
					desc = "Chmod on selected files";
				}
				{
					on = ["M"];
					run = "plugin mount";
					desc = "Open mount menu";
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
