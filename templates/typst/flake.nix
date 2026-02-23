# Typst Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#typst
#
# Provides a complete Typst document development environment with:
# - Typst compiler
# - Typst LSP for editor integration
# - PDF viewer (zathura)
# - Watch mode for automatic recompilation
# - Common fonts
{
  description = "Typst document development environment";

  inputs = {
    nix-shell-templates.url = "github:sibeov/nix-shell-templates";
    nixpkgs.follows = "nix-shell-templates/nixpkgs";
    flake-parts.follows = "nix-shell-templates/flake-parts";
    devshell.follows = "nix-shell-templates/devshell";
  };

  outputs =
    inputs@{
      self,
      nix-shell-templates,
      nixpkgs,
      flake-parts,
      devshell,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devshell.flakeModule
        nix-shell-templates.flakeModules.common
        nix-shell-templates.flakeModules.typst
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Project configuration
      templates.projectName = "typst-document";

      # Typst module configuration
      templates.typst = {
        enable = true;

        # LSP for editor integration
        includeLsp = true;

        # PDF viewer
        includePdfViewer = true;

        # Watch mode support
        includeWatchTools = true;

        # Include common fonts
        includeFonts = true;

        # Default output format
        defaultFormat = "pdf";

        # Additional fonts (uncomment as needed)
        extraFonts = [
          # pkgs.inter
          # pkgs.roboto
        ];

        # Extra packages
        extraPackages = [ ];
      };

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          # Default formatter
          formatter = pkgs.alejandra;

          # Make the Typst shell the default
          devShells.default = config.devShells.typst;
        };
    };
}
