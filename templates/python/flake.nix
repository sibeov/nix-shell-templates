# Python Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#python
#
# A standalone Python development environment using:
# - .python-version: Python version (pyenv-compatible)
# - pyproject.toml: Project config with tool settings (ruff, mypy, pyright, etc.)
#
# This template is Nix-agnostic: the same configuration files work with
# pyenv, uv, pip, and other Python tooling outside of Nix.
{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      # Supported systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Helper to generate per-system attributes
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Read Python version from .python-version file
      # Format: "3.13" or "3.13.1" (we use major.minor)
      pythonVersionFile = builtins.readFile ./.python-version;
      pythonVersionRaw = builtins.head (builtins.split "\n" pythonVersionFile);

      # Map version string to nixpkgs Python package name
      # "3.13" -> "python313", "3.12" -> "python312", etc.
      pythonVersionParts = builtins.split "\\." pythonVersionRaw;
      pythonMajor = builtins.elemAt pythonVersionParts 0;
      pythonMinor = builtins.elemAt pythonVersionParts 2;
      pythonPkgName = "python${pythonMajor}${pythonMinor}";
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Get Python from nixpkgs
          python = pkgs.${pythonPkgName} or pkgs.python3;

          # Virtual environment directory
          venvDir = ".venv";

          # Development tools from nixpkgs
          devTools = [
            pkgs.uv # Fast Python package manager
            pkgs.ruff # Linter and formatter
            pkgs.mypy # Type checker
            pkgs.pyright # Type checker (alternative)
          ];
        in
        {
          default = pkgs.mkShell {
            name = "python-dev";

            packages = [ python ] ++ devTools;

            env = {
              PYTHONDONTWRITEBYTECODE = "1";
              PYTHONUNBUFFERED = "1";
            };

            shellHook = ''
              # Create venv if it doesn't exist
              if [ ! -d "${venvDir}" ]; then
                echo "Creating virtual environment in ${venvDir}..."
                uv venv ${venvDir}
              fi

              # Activate venv
              source "${venvDir}/bin/activate"

              echo ""
              echo "Python Development Environment"
              echo "==============================="
              echo "Python: $(python --version)"
              echo "uv:     $(uv --version)"
              echo "Venv:   ${venvDir}"
              echo ""
              echo "Commands:"
              echo "  uv pip install <pkg>  - Install packages"
              echo "  uv pip sync           - Sync from requirements"
              echo "  uv pip compile        - Lock dependencies"
              echo "  ruff check .          - Lint code"
              echo "  ruff format .         - Format code"
              echo "  mypy .                - Type check"
              echo ""
            '';
          };
        }
      );
    };
}
