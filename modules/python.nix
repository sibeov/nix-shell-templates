# Python development module
#
# Provides a Python development environment using:
# - .python-version file for Python version (pyenv-compatible)
# - uv for fast package management
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates.python;

  # Parse .python-version file to get nixpkgs Python package name
  # File format: "3.13" or "3.13.1" (we use major.minor)
  parsePythonVersion =
    versionFile:
    let
      content = builtins.readFile versionFile;
      versionRaw = builtins.head (builtins.split "\n" content);
      parts = builtins.split "\\." versionRaw;
      major = builtins.elemAt parts 0;
      minor = builtins.elemAt parts 2;
    in
    "python${major}${minor}";
in
{
  options.templates.python = {
    enable = lib.mkEnableOption "Python development environment";

    # Python version file (required)
    pythonVersionFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to .python-version file containing the Python version.
        Format: "3.13" or "3.13.1" (major.minor used).
        This file is compatible with pyenv and other Python version managers.
      '';
      example = lib.literalExpression "./.python-version";
    };

    # Virtual environment directory
    venvDir = lib.mkOption {
      type = lib.types.str;
      default = ".venv";
      description = "Virtual environment directory name";
    };

    # Include development tools
    includeDevTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include development tools (ruff, mypy, pyright)";
    };

    # Include Jupyter
    includeJupyter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include Jupyter notebook support";
    };

    # Additional Nix packages
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
        # Get Python version from file
        pythonPkgName = parsePythonVersion cfg.pythonVersionFile;
        python = pkgs.${pythonPkgName} or pkgs.python3;

        # Development tools
        devTools = lib.optionals cfg.includeDevTools [
          pkgs.uv
          pkgs.ruff
          pkgs.mypy
          pkgs.pyright
        ];

        # Jupyter support
        jupyterPkgs = lib.optionals cfg.includeJupyter [
          (python.withPackages (ps: [
            ps.jupyter
            ps.ipython
          ]))
        ];

        # All packages
        allPackages = [
          python
        ]
        ++ devTools
        ++ jupyterPkgs
        ++ cfg.extraPackages
        ++ config.templates.commonPackages;

        # Venv setup script
        venvSetupScript = ''
          if [ ! -d "${cfg.venvDir}" ]; then
            echo "Creating virtual environment in ${cfg.venvDir}..."
            uv venv ${cfg.venvDir}
          fi
          source "${cfg.venvDir}/bin/activate"
          echo "Virtual environment activated: ${cfg.venvDir}"
        '';
      in
      {
        devshells.python = {
          name = "python-dev";
          motd = ''
            {202}Python Development Environment{reset}
            {bold}Python: ${pythonPkgName} | Package Manager: uv{reset}
            Virtual env: ${cfg.venvDir}

            $(type -p menu &>/dev/null && menu)
          '';

          packages = allPackages;

          env = [
            {
              name = "PYTHONDONTWRITEBYTECODE";
              value = "1";
            }
            {
              name = "PYTHONUNBUFFERED";
              value = "1";
            }
            {
              name = "VIRTUAL_ENV";
              eval = "$PRJ_ROOT/${cfg.venvDir}";
            }
          ];

          devshell.startup.python-venv.text = venvSetupScript;

          commands = [
            {
              name = "py-info";
              help = "Show Python environment information";
              command = ''
                echo "Python: $(python --version)"
                echo "uv: $(uv --version)"
                echo "Venv: $VIRTUAL_ENV"
              '';
            }
            {
              name = "py-install";
              help = "Install Python packages";
              command = "uv pip install \"$@\"";
              category = "packages";
            }
            {
              name = "py-sync";
              help = "Sync packages from requirements.txt or pyproject.toml";
              command = ''
                if [ -f "pyproject.toml" ]; then
                  uv pip install -e .
                elif [ -f "requirements.txt" ]; then
                  uv pip sync requirements.txt
                else
                  echo "No pyproject.toml or requirements.txt found"
                fi
              '';
              category = "packages";
            }
            {
              name = "lint";
              help = "Run ruff linter";
              command = "ruff check .";
              category = "quality";
            }
            {
              name = "format";
              help = "Format code with ruff";
              command = "ruff format .";
              category = "quality";
            }
            {
              name = "typecheck";
              help = "Run mypy type checker";
              command = "mypy .";
              category = "quality";
            }
          ];
        };
      };
  };
}
