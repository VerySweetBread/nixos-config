{ inputs, pkgs, lib, config, ... }: let
  helixSteel =
    (inputs.helix-steel.packages.${pkgs.system}.default.override {
      grammarOverlays = [
        (_: prev: {
          perl = prev.perl.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace src/bsearch.c --replace-fail 'void *bsearch(' 'void *tsp_bsearch('
              substituteInPlace src/tsp_unicode.h --replace-fail 'return bsearch(' 'return tsp_bsearch('
            '';
          });
        })
      ];
    }).overrideAttrs (old: {
      cargoBuildFlags = (old.cargoBuildFlags or []) ++ [
        "--features"
        "steel,git"
      ];
    });

  comment-headers = pkgs.fetchurl {
    url = "https://github.com/codingvivi/comment-dividers.hx/raw/refs/heads/main/comment_headers.scm";
    name = "comment_headers.scm";
    hash = "sha256-ohgn6DFJl0rdRJuri6Frs/uUlUsPxMvPHDuw4FS3qEE=";
  };

  patched-comment-headers = pkgs.runCommand "comment_headers.scm" { } ''
    install -m 0644 ${comment-headers} "$out"

    ${pkgs.python3}/bin/python3 - <<'PY'
    from pathlib import Path
    import os
    import sys

    p = Path(os.environ["out"])
    s = p.read_text()

    start_marker = "(define (get-block-delims)"
    end_marker = "(define (delete_till_first_nonwhitespace!)"

    try:
        start = s.index(start_marker)
        end = s.index(end_marker, start)
    except ValueError as e:
        sys.exit(f"failed to find function markers: {e}")

    new_get_block_delims = """(define (get-block-delims)
      (helix.static.open_above)
      (helix.static.insert_string "test_string")
      (helix.static.normal_mode)
      (helix.static.extend_to_line_bounds)
      (helix.static.trim_selections)
      (helix.static.toggle_comments)
      (let* ([commented-test-string (helix.static.current-highlighted-text!)]
             [strings-without-whitespace (split-whitespace commented-test-string)])
        (delete-line-noyank!)
        (cond
          [(and (> (length strings-without-whitespace) 1)
                (equal? (last strings-without-whitespace) "test_string"))
           (list (first strings-without-whitespace) "")]
          [(> (length strings-without-whitespace) 2)
           (list (first strings-without-whitespace) (last strings-without-whitespace))]
          [else
           (list "" "")])))

    """

    s = s[:start] + new_get_block_delims + s[end:]

    old = "(make-line line-length fill-pattern #f padding-pattern)"
    new = "(make-line line-length \"\" fill-pattern padding-pattern)"

    if old not in s:
        sys.exit("failed to find insert-divider make-line call")

    s = s.replace(old, new)

    p.write_text(s)
    PY
  '';
in {
  home.packages = with pkgs; [
    asm-lsp
    fasm
    steel
    wakatime-cli
  ];

  home.activation.installWakatimeHx = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.steel}/bin:$PATH"
    export STEEL_HOME="${config.xdg.dataHome}/steel"

    if [ ! -f "$STEEL_HOME/cogs/wakatime/wakatime.scm" ]; then
      forge pkg install --git https://github.com/Xerxes-2/wakatime.hx.git
    fi
  '';

  programs.helix = {
    enable = true;
    package = helixSteel;
    defaultEditor = true;

    languages = {
      language-server.asm-lsp.command = "asm-lsp";

      language = [
        {
          name = "nasm";
          file-types = [ "asm" "inc" ];
          comment-token = ";";
          language-servers = [ "asm-lsp" ];
        }
      ];
    };

    settings = {
      # theme = "catppuccin-mocha";
      editor = {
        rulers = [ 81 ];
        insert-final-newline = false;
        indent-guides.render = true;

        whitespace.render = {
          space = "all";
          tab = "all";
          nbsp = "none";
          nnbsp = "none";
          newline = "none";
        };

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };

      keys.normal = {
        space = {
          C-a = {
            b = ":fasm-build";
            r = ":fasm-run";
            c = ":fasm-clean";
          };

          C-c = {
            h = ":comment-h1";
            j = ":comment-h2";
            k = ":comment-h3";
            d = ":comment-divider";
          };
        };

        S-down = ["extend_to_line_bounds" "delete_selection" "paste_after"];
        S-up = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before"];
      };
    };
  };

  xdg.configFile = {
    "asm-lsp/.asm-lsp.toml".text = ''
      [default_config]
      assembler = "fasm"
      instruction_set = "x86/x86-64"

      [opts]
      compiler = "fasm"
      diagnostics = true
      default_diagnostics = true
    '';

    "helix/cogs/comment_headers.scm".source = patched-comment-headers;
    "helix/helix.scm".text = ''
      (require (prefix-in div. "cogs/comment_headers.scm"))
      (require (prefix-in helix. "helix/commands.scm"))

      (provide comment-h1
               comment-h2
               comment-h3
               comment-divider
               fasm-build
               fasm-run
               fasm-clean)

      (define (comment-h1)
        (div.insert-h1!))

      (define (comment-h2)
        (div.insert-h2!))

      (define (comment-h3)
        (div.insert-h3!))

      (define (comment-divider)
        (div.insert-divider! 80 "~"))

      (define (fasm-build)
        (helix.write)
        (helix.run-shell-command "just" "build"))

      (define (fasm-run)
        (helix.write)
        (helix.run-shell-command "just" "run"))

      (define (fasm-clean)
        (helix.run-shell-command "just" "clean"))
    '';
    "helix/init.scm".text = ''
      ;; Steel init file
      (require "wakatime/wakatime.scm")
    '';
  };
}
