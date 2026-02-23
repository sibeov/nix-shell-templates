# Project Structure

Understanding how nix-shell-templates is organized helps you customize and extend it.

## Repository Layout

```
nix-shell-templates/
├── flake.nix              # Main flake definition
├── flake.lock             # Pinned dependency versions
├── modules/               # Flake-parts modules
│   ├── common.nix         # Shared options and configuration
│   ├── fpga.nix           # FPGA development module
│   ├── rust.nix           # Rust development module
│   ├── python.nix         # Python development module
│   └── typst.nix          # Typst development module
├── containers/
│   └── flake-module.nix   # OCI container building module
├── templates/             # nix flake init templates
│   ├── default/           # All modules (manual enable)
│   ├── fpga/              # FPGA-specific template
│   ├── rust/              # Rust-specific template
│   ├── python/            # Python-specific template
│   ├── typst/             # Typst-specific template
│   └── oss-cad-suite.nix  # OSS CAD Suite package
└── doc/                   # This documentation
```

## Key Concepts

### Flake Modules

Each module in `modules/` is a [flake-parts module](https://flake.parts/module-arguments.html) that:

1. **Declares options** under the `templates` namespace
2. **Implements behavior** when enabled via `lib.mkIf cfg.enable`
3. **Creates devshells** using numtide/devshell

Example structure:

```nix
{ lib, config, ... }:
let
  cfg = config.templates.moduleName;
in
{
  options.templates.moduleName = {
    enable = lib.mkEnableOption "Module description";
    # ... more options
  };

  config = lib.mkIf cfg.enable {
    perSystem = { pkgs, ... }: {
      devshells.moduleName = {
        # Shell configuration
      };
    };
  };
}
```

### Templates

Templates in `templates/` are complete flake configurations that:

1. Import the necessary modules from this flake
2. Pre-configure sensible defaults
3. Provide a starting point for customization

When you run `nix flake init -t`, it copies the template's `flake.nix` to your project.

### Containers

The containers module creates OCI-compliant images that mirror your development environment. This enables:

- Consistent CI/CD pipelines
- Sharing environments with non-Nix users
- Production deployments

## Exported Outputs

The flake exports:

| Output | Description |
|--------|-------------|
| `flakeModules.*` | Import into your own flake-parts configuration |
| `templates.*` | Use with `nix flake init -t` |
| `devShells.*` | Development shells for each module |
| `packages.*` | Standalone packages (oss-cad-suite, rust-toolchain, etc.) |

## Using as a Dependency

You can import modules directly into your flake:

```nix
{
  inputs.nix-shell-templates.url = "github:sibeov/nix-shell-templates";
  
  outputs = { self, nix-shell-templates, ... }:
    flake-parts.lib.mkFlake { ... } {
      imports = [
        nix-shell-templates.flakeModules.rust
        nix-shell-templates.flakeModules.python
      ];
      
      # Configure the modules
      templates.rust.enable = true;
      templates.python.enable = true;
    };
}
```
