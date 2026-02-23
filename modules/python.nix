# Python development module
#
# Provides a modern Python development environment.
# Supports virtualenv, pip, and optional uv (fast package manager).
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates.python;
in
{
  options.templates.python = {
    enable = lib.mkEnableOption "Python development environment";

    # Python version
    pythonVersion = lib.mkOption {
      type = lib.types.enum [
        "python3"
        "python311"
        "python312"
        "python313"
      ];
      default = "python312";
      description = "Python version to use";
    };

    # Enable virtualenv support
    withVenv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable virtualenv support with automatic venv creation";
    };

    # Venv directory name
    venvDir = lib.mkOption {
      type = lib.types.str;
      default = ".venv";
      description = "Virtual environment directory name";
    };

    # Use uv instead of pip
    useUv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use uv (fast Python package manager) instead of pip";
    };

    # Include development tools
    includeDevTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include common development tools (black, ruff, mypy, pytest)";
    };

    # Include Jupyter
    includeJupyter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include Jupyter notebook support";
    };

    # Additional Python packages (as strings, installed via pip/uv)
    pythonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "requests"
        "numpy"
        "pandas"
      ];
      description = "Python packages to install in the virtual environment";
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
        # Select Python version
        python = pkgs.${cfg.pythonVersion};

        # Development tools
        devTools = lib.optionals cfg.includeDevTools [
          pkgs.ruff
          pkgs.mypy
        ];

        # Package manager
        packageManager = if cfg.useUv then [ pkgs.uv ] else [ ];

        # Jupyter support
        jupyterPkgs = lib.optionals cfg.includeJupyter [
          (python.withPackages (ps: [
            ps.jupyter
            ps.ipython
          ]))
        ];

        # All Python-related packages
        pythonPackages = [
          python
        ]
        ++ packageManager
        ++ devTools
        ++ jupyterPkgs
        ++ cfg.extraPackages
        ++ config.templates.commonPackages;

        # Venv setup script
        venvSetupScript =
          if cfg.withVenv then
            ''
              if [ ! -d "${cfg.venvDir}" ]; then
                echo "Creating virtual environment in ${cfg.venvDir}..."
                ${if cfg.useUv then "uv venv ${cfg.venvDir}" else "${python}/bin/python -m venv ${cfg.venvDir}"}
              fi
              source "${cfg.venvDir}/bin/activate"
              echo "Virtual environment activated: ${cfg.venvDir}"
            ''
          else
            "";

        # Package install command
        installCmd = if cfg.useUv then "uv pip install" else "pip install";
      in
      {
        # Development shell using devshell
        devshells.python = {
          name = "python-dev";
          motd = ''
            {202}Python Development Environment{reset}
            {bold}Python: ${cfg.pythonVersion}${lib.optionalString cfg.useUv " | Package Manager: uv"}{reset}
            ${lib.optionalString cfg.withVenv "Virtual env: ${cfg.venvDir}"}

            $(type -p menu &>/dev/null && menu)
          '';

          packages = pythonPackages;

          env = [
            {
              name = "PYTHONDONTWRITEBYTECODE";
              value = "1";
            }
            {
              name = "PYTHONUNBUFFERED";
              value = "1";
            }
          ]
          ++ lib.optionals cfg.withVenv [
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
                echo "Pip: $(pip --version 2>/dev/null || echo 'not available')"
                ${lib.optionalString cfg.useUv "echo \"uv: $(uv --version)\""}
                ${lib.optionalString cfg.withVenv "echo \"Venv: $VIRTUAL_ENV\""}
              '';
            }
            {
              name = "py-install";
              help = "Install Python packages";
              command = "${installCmd} \"$@\"";
              category = "packages";
            }
            {
              name = "py-sync";
              help = "Sync packages from requirements.txt";
              command = if cfg.useUv then "uv pip sync requirements.txt" else "pip install -r requirements.txt";
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
