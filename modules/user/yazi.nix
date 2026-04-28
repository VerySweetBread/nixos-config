{ pkgs, lib, inputs, ... }: {
	home.packages = with pkgs; [
		( ouch.override { enableUnfree = true; } )
	];

	wayland.windowManager.hyprland.settings.windowrule = [
		"match:class dragon-drop, move cursor_x-window_w/2 cursor_y-window_h/2"
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
					{ url = "*.crdownload"; run = "noop"; }
				];

				prepend_previewers = [
					{ mime = "application/xz";            run = "ouch"; }
					{ mime = "application/zip";           run = "ouch"; }
					{ mime = "application/rar";           run = "ouch"; }
					{ mime = "application/gzip";          run = "ouch"; }
					{ mime = "application/7z-compressed"; run = "ouch"; }
				];

				prepend_fetchers = [
					{ group = "git"; url = "*"; run = "git"; }
				];
			};
		};

		plugins = let
			yaziPlugin = name: pkgs.stdenvNoCC.mkDerivation {
		    pname = "${name}.yazi";
		    version = "unstable";
		    src = inputs.yazi-plugins;

		    installPhase = ''
		      runHook preInstall
		      mkdir -p $out
		      cp -r ${name}.yazi/* $out/
		      rm -f $out/LICENSE
		      cp LICENSE $out/LICENSE
		      runHook postInstall
		    '';
		  };
		in with pkgs.yaziPlugins; {
			inherit
				chmod
				ouch
				mount
				toggle-pane
			;
			
			full-border = {
				package = yaziPlugin "full-border";
				setup = true;
			};

			starship = {
				package = starship;
				setup = true;
			};

			git = {
				package = git;
				setup = true;
			};
		};

		initLua = ''
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
					run = ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list'';
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
