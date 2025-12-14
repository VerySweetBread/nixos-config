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

			Status:children_add(function()
				local h = cx.active.current.hovered
				if not h or ya.target_family() ~= "unix" then
					return ""
				end

				return ui.Line {
					ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
					":",
					ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
					" ",
				}
			end, 500, Status.RIGHT)
		'';

		keymap = {
			mgr.prepend_keymap = [
				{
					on = "T";
					run = "plugin toggle-pane max-preview";
					desc = "Maximize or restore the preview pane";
				}
				{
					on = "Y";
					run = ''shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list'';
					desc = "Copy files into system clipboard";
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
					run = "shell '${lib.getExe pkgs.dragon-drop} -x -A -i -T %s'";
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
