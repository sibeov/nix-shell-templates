# Typst development module
#
# Provides a Typst document development environment.
# Includes typst compiler, LSP, and PDF preview tools.
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates.typst;
in
{
  options.templates.typst = {
    enable = lib.mkEnableOption "Typst development environment";

    # Include LSP for editor integration
    includeLsp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Typst LSP for editor integration";
    };

    # Include PDF viewer
    includePdfViewer = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include a PDF viewer (zathura)";
    };

    # Watch mode support
    includeWatchTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include tools for watch mode (automatic recompilation)";
    };

    # Font packages
    includeFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include common font packages";
    };

    # Additional fonts
    extraFonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional font packages to include";
    };

    # Output format
    defaultFormat = lib.mkOption {
      type = lib.types.enum [
        "pdf"
        "png"
        "svg"
      ];
      default = "pdf";
      description = "Default output format for compilation";
    };

    # Additional packages
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional Nix packages to include";
    };
  };

  config = lib.mkIf cfg.enable {
    perSystem =
      { pkgs, ... }:
      let
        # Core Typst package
        typstPkg = pkgs.typst;

        # LSP
        lspPkgs = lib.optionals cfg.includeLsp [
          pkgs.typst-lsp
          pkgs.tinymist
        ];

        # PDF viewer
        viewerPkgs = lib.optionals cfg.includePdfViewer [
          pkgs.zathura
        ];

        # Watch tools
        watchPkgs = lib.optionals cfg.includeWatchTools [
          pkgs.watchexec
        ];

        # Font packages
        fontPkgs = lib.optionals cfg.includeFonts [
          pkgs.liberation_ttf
          pkgs.noto-fonts
          pkgs.noto-fonts-emoji
          pkgs.fira-code
          pkgs.fira-mono
          pkgs.source-serif
          pkgs.source-sans
          pkgs.source-code-pro
        ];

        # All Typst-related packages
        typstPackages = [
          typstPkg
        ]
        ++ lspPkgs
        ++ viewerPkgs
        ++ watchPkgs
        ++ fontPkgs
        ++ cfg.extraFonts
        ++ cfg.extraPackages
        ++ config.templates.commonPackages;

        # Font directory setup
        fontPaths = lib.concatStringsSep ":" (map (f: "${f}/share/fonts") fontPkgs);
      in
      {
        # Export typst as a package
        packages.typst = typstPkg;

        # Development shell using devshell
        devshells.typst = {
          name = "typst-dev";
          motd = ''
            {202}Typst Document Development{reset}
            {bold}Typst: $(typst --version 2>/dev/null || echo 'loading...'){reset}
            Default format: ${cfg.defaultFormat}

            $(type -p menu &>/dev/null && menu)
          '';

          packages = typstPackages;

          env = [
            {
              name = "TYPST_FONT_PATHS";
              value = fontPaths;
            }
          ]
          ++ lib.optionals cfg.includeFonts [
            {
              name = "FONTCONFIG_PATH";
              value = "${pkgs.fontconfig.out}/etc/fonts";
            }
          ];

          commands = [
            {
              name = "typst-info";
              help = "Show Typst environment information";
              command = ''
                echo "Typst: $(typst --version)"
                ${lib.optionalString cfg.includeLsp "echo \"LSP: $(typst-lsp --version 2>/dev/null || echo 'available')\""}
                echo "Font paths: $TYPST_FONT_PATHS"
              '';
            }
            {
              name = "compile";
              help = "Compile a Typst document to ${cfg.defaultFormat}";
              command = ''
                if [ -z "$1" ]; then
                  echo "Usage: compile <file.typ> [output]"
                  exit 1
                fi
                input="$1"
                output="''${2:-''${input%.typ}.${cfg.defaultFormat}}"
                typst compile --format ${cfg.defaultFormat} "$input" "$output"
                echo "Compiled: $output"
              '';
              category = "build";
            }
            {
              name = "watch";
              help = "Watch and recompile on changes";
              command = ''
                if [ -z "$1" ]; then
                  echo "Usage: watch <file.typ>"
                  exit 1
                fi
                typst watch "$1"
              '';
              category = "build";
            }
            {
              name = "preview";
              help = "Compile and open PDF for preview";
              command = ''
                if [ -z "$1" ]; then
                  echo "Usage: preview <file.typ>"
                  exit 1
                fi
                input="$1"
                output="''${input%.typ}.pdf"
                typst compile "$input" "$output"
                ${lib.optionalString cfg.includePdfViewer "zathura \"$output\" &"}
              '';
              category = "build";
            }
            {
              name = "watch-preview";
              help = "Watch, recompile, and auto-refresh PDF";
              command = ''
                if [ -z "$1" ]; then
                  echo "Usage: watch-preview <file.typ>"
                  exit 1
                fi
                input="$1"
                output="''${input%.typ}.pdf"
                # Start zathura in background (it auto-reloads on file change)
                ${lib.optionalString cfg.includePdfViewer "zathura \"$output\" 2>/dev/null &"}
                # Watch and recompile
                typst watch "$input"
              '';
              category = "build";
            }
          ];
        };
      };
  };
}
