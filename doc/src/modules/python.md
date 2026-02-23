# Python Module

Provides a modern Python development environment using standard configuration files.

## Philosophy

This module is designed to be **Nix-agnostic**. Your project configuration lives in standard files that work everywhere:

| File | Purpose |
|------|---------|
| `.python-version` | Python version (pyenv-compatible) |
| `pyproject.toml` | Project metadata and tool configuration |

The same configuration works with Nix, pyenv, uv, pip, and any other Python tooling.

## Features

- **Standard configuration**: `.python-version` and `pyproject.toml`
- **Fast package management**: uv by default
- **Automatic virtualenv**: Created on shell entry
- **Development tools**: ruff, mypy, pyright included

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#python
nix develop
```

This creates:
- `flake.nix` - Standalone Nix flake (no module dependencies)
- `.python-version` - Python version (default: 3.13)
- `pyproject.toml` - Project scaffold with tool configuration

## Configuration Files

### .python-version

Simple file containing the Python version:

```
3.13
```

This format is compatible with:
- pyenv
- asdf
- mise
- uv (reads automatically)

### pyproject.toml

Standard Python project configuration:

```toml
[project]
name = "my-project"
requires-python = ">=3.13, <3.14"
dependencies = []

[tool.ruff]
line-length = 100
target-version = "py313"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]

[tool.mypy]
python_version = "3.13"
strict = false

[tool.pyright]
pythonVersion = "3.13"
typeCheckingMode = "basic"
```

## Using the Module

If using the flake module system (instead of the standalone template):

```nix
{
  imports = [
    nix-shell-templates.flakeModules.python
  ];

  templates.python = {
    enable = true;
    pythonVersionFile = ./.python-version;  # Required
  };
}
```

### Module Options

#### `templates.python.pythonVersionFile`

| Property | Value |
|----------|-------|
| Type | `path` |
| Required | Yes |

Path to `.python-version` file. Format: `3.13` or `3.13.1` (major.minor used).

#### `templates.python.venvDir`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `".venv"` |

Virtual environment directory name.

#### `templates.python.includeDevTools`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include development tools (ruff, mypy, pyright).

#### `templates.python.includeJupyter`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Include Jupyter notebook support.

#### `templates.python.extraPackages`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Additional Nix packages to include.

## Shell Commands

| Command | Description |
|---------|-------------|
| `py-info` | Show Python environment information |
| `py-install <packages>` | Install Python packages with uv |
| `py-sync` | Sync from pyproject.toml or requirements.txt |
| `lint` | Run ruff linter |
| `format` | Format code with ruff |
| `typecheck` | Run mypy type checker |

## Environment Variables

| Variable | Value |
|----------|-------|
| `PYTHONDONTWRITEBYTECODE` | `1` |
| `PYTHONUNBUFFERED` | `1` |
| `VIRTUAL_ENV` | `$PRJ_ROOT/.venv` |

## Example Configurations

### Data science setup

```nix
templates.python = {
  enable = true;
  pythonVersionFile = ./.python-version;
  includeJupyter = true;
  extraPackages = with pkgs; [
    # System libraries for scipy, etc.
    openblas
    lapack
  ];
};
```

### Web development

```nix
templates.python = {
  enable = true;
  pythonVersionFile = ./.python-version;
  extraPackages = with pkgs; [
    postgresql
    redis
  ];
};
```

## Workflow

1. **Enter shell**: `nix develop`
2. **Venv created**: Automatically in `.venv/`
3. **Install deps**: `uv pip install -e .` or `py-sync`
4. **Add packages**: `uv add requests` (updates pyproject.toml)
5. **Lint**: `lint` or `ruff check .`
6. **Format**: `format` or `ruff format .`
7. **Type check**: `typecheck` or `mypy .`

## Why This Approach?

### Cross-Environment Compatibility

Your `.python-version` works with:
- **Nix**: Reads and maps to nixpkgs Python
- **pyenv**: Native support
- **asdf/mise**: Native support
- **uv**: Reads automatically for venv creation

Your `pyproject.toml` works with:
- **uv**: `uv pip install -e .`, `uv add`, `uv sync`
- **pip**: `pip install -e .`
- **setuptools**: Standard build backend
- **ruff/mypy/pyright**: Read `[tool.*]` sections

### Why uv?

[uv](https://github.com/astral-sh/uv) is a fast Python package manager written in Rust:

- **10-100x faster** than pip
- **Compatible** with pip interface
- **Reliable** dependency resolution
- **Built-in** venv creation
- **Reads** `.python-version` automatically

## Changing Python Version

1. Edit `.python-version`:
   ```
   3.12
   ```

2. Update `pyproject.toml` tool sections:
   ```toml
   [tool.ruff]
   target-version = "py312"

   [tool.mypy]
   python_version = "3.12"

   [tool.pyright]
   pythonVersion = "3.12"
   ```

3. Re-enter the shell:
   ```bash
   exit
   nix develop
   ```
