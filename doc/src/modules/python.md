# Python Module

Provides a modern Python development environment with virtualenv support.

## Features

- **Python versions**: 3.11, 3.12, 3.13
- **Fast package management**: uv by default
- **Automatic virtualenv**: Created on shell entry
- **Development tools**: ruff, mypy included
- **Jupyter support**: Optional notebook environment

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#python
nix develop
```

## Options

### `templates.python.enable`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable the Python development environment.

### `templates.python.pythonVersion`

| Property | Value |
|----------|-------|
| Type | `enum: "python3"`, `"python311"`, `"python312"`, `"python313"` |
| Default | `"python312"` |

Python version to use.

### `templates.python.withVenv`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Enable virtualenv support with automatic venv creation on shell entry.

### `templates.python.venvDir`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `".venv"` |

Virtual environment directory name.

### `templates.python.useUv`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Use [uv](https://github.com/astral-sh/uv) (fast Python package manager) instead of pip.

### `templates.python.includeDevTools`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include common development tools (ruff, mypy).

### `templates.python.includeJupyter`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Include Jupyter notebook support.

### `templates.python.pythonPackages`

| Property | Value |
|----------|-------|
| Type | `list of string` |
| Default | `[]` |
| Example | `["requests", "numpy", "pandas"]` |

Python packages to install in the virtual environment (via pip/uv).

### `templates.python.extraPackages`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Additional Nix packages to include.

## Shell Commands

| Command | Description |
|---------|-------------|
| `py-info` | Show Python environment information |
| `py-install <packages>` | Install Python packages |
| `py-sync` | Sync packages from requirements.txt |
| `lint` | Run ruff linter |
| `format` | Format code with ruff |
| `typecheck` | Run mypy type checker |

## Environment Variables

| Variable | Value |
|----------|-------|
| `PYTHONDONTWRITEBYTECODE` | `1` |
| `PYTHONUNBUFFERED` | `1` |
| `VIRTUAL_ENV` | `$PRJ_ROOT/.venv` (when withVenv enabled) |

## Example Configurations

### Data science setup

```nix
templates.python = {
  enable = true;
  pythonVersion = "python312";
  includeJupyter = true;
  pythonPackages = [
    "numpy"
    "pandas"
    "matplotlib"
    "scikit-learn"
  ];
};
```

### Web development

```nix
templates.python = {
  enable = true;
  pythonVersion = "python312";
  pythonPackages = [
    "fastapi"
    "uvicorn"
    "sqlalchemy"
    "pydantic"
  ];
  extraPackages = with pkgs; [
    postgresql
    redis
  ];
};
```

### Using pip instead of uv

```nix
templates.python = {
  enable = true;
  useUv = false;
};
```

### Custom venv location

```nix
templates.python = {
  enable = true;
  venvDir = ".python-venv";
};
```

## Workflow

1. **Enter shell**: `nix develop`
2. **Venv created**: Automatically in `.venv/`
3. **Install deps**: `py-install requests` or edit `requirements.txt` then `py-sync`
4. **Lint**: `lint` (runs ruff)
5. **Format**: `format` (runs ruff format)
6. **Type check**: `typecheck` (runs mypy)

## Why uv?

[uv](https://github.com/astral-sh/uv) is a fast Python package installer written in Rust:

- **10-100x faster** than pip
- **Compatible** with pip's interface
- **Reliable** dependency resolution
- **Built-in venv** creation

Set `useUv = false` if you prefer traditional pip.
