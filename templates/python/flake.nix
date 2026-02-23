# Python Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#python
#
# Provides a complete Python development environment with:
# - Python 3.12 (configurable)
# - uv (fast package manager) or pip
# - Virtual environment support
# - ruff, mypy for linting and type checking
{
  description = "Python development environment";

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
        nix-shell-templates.flakeModules.python
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Project configuration
      templates.projectName = "python-project";

      # Python module configuration
      templates.python = {
        enable = true;

        # Python version
        pythonVersion = "python312";

        # Virtual environment settings
        withVenv = true;
        venvDir = ".venv";

        # Use uv for fast package management
        useUv = true;

        # Include dev tools (ruff, mypy)
        includeDevTools = true;

        # Jupyter notebook support (uncomment if needed)
        includeJupyter = false;

        # Python packages to install (via pip/uv)
        pythonPackages = [
          # "requests"
          # "numpy"
          # "pandas"
        ];

        # Extra Nix packages
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
          # Default formatter (official Nix formatter per RFC 166)
          formatter = pkgs.nixfmt;

          # Make the Python shell the default
          devShells.default = config.devShells.python;
        };
    };
}
