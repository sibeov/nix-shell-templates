# Using Templates

Templates provide ready-to-use flake configurations for quick project setup.

## Available Templates

| Template | Command | Description |
|----------|---------|-------------|
| default | `nix flake init -t github:sibeov/nix-shell-templates` | All modules (enable manually) |
| fpga | `nix flake init -t github:sibeov/nix-shell-templates#fpga` | FPGA development |
| rust | `nix flake init -t github:sibeov/nix-shell-templates#rust` | Rust development |
| python | `nix flake init -t github:sibeov/nix-shell-templates#python` | Python development |
| typst | `nix flake init -t github:sibeov/nix-shell-templates#typst` | Typst documents |

## How Templates Work

When you run `nix flake init -t`, Nix copies the template's `flake.nix` to your project directory. This file:

1. **Imports modules** from nix-shell-templates
2. **Configures options** with sensible defaults
3. **Sets up devshells** ready for immediate use

## Template Structure

Each template follows this pattern:

```nix
{
  description = "My project";

  inputs = {
    nix-shell-templates.url = "github:sibeov/nix-shell-templates";
    nixpkgs.follows = "nix-shell-templates/nixpkgs";
    flake-parts.follows = "nix-shell-templates/flake-parts";
    devshell.follows = "nix-shell-templates/devshell";
    # ... other inputs as needed
  };

  outputs = inputs@{ ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devshell.flakeModule
        nix-shell-templates.flakeModules.common
        nix-shell-templates.flakeModules.moduleName
      ];

      templates.moduleName = {
        enable = true;
        # ... configuration
      };

      perSystem = { pkgs, config, ... }: {
        devShells.default = config.devShells.moduleName;
      };
    };
}
```

## Choosing a Template

### Default Template

Use when you need **multiple modules** or want to **explore options**:

```bash
nix flake init -t github:sibeov/nix-shell-templates
```

Then edit `flake.nix` to uncomment the modules you need.

### Specific Templates

Use when you know exactly what you need:

```bash
# Pure Rust project
nix flake init -t github:sibeov/nix-shell-templates#rust

# Python data science
nix flake init -t github:sibeov/nix-shell-templates#python

# Hardware project
nix flake init -t github:sibeov/nix-shell-templates#fpga

# Writing documents
nix flake init -t github:sibeov/nix-shell-templates#typst
```

## After Initialization

1. **Review configuration**: Open `flake.nix` and adjust options
2. **Enter shell**: `nix develop`
3. **Optional**: Add `.envrc` with `use flake` for direnv

## Combining Templates

The default template includes all modules. Enable multiple:

```nix
# In flake.nix after using default template
templates.rust.enable = true;
templates.python.enable = true;
```

This creates separate devshells:
- `nix develop .#rust`
- `nix develop .#python`

Set a default:

```nix
perSystem = { config, ... }: {
  devShells.default = config.devShells.rust;
};
```

## Updating Templates

Templates are copied, not linked. To get updates:

1. Check the [changelog](https://github.com/sibeov/nix-shell-templates/releases)
2. Manually update your `flake.nix` if needed
3. Run `nix flake update` to get latest module versions

The `flake.lock` in your project pins the version of nix-shell-templates.
