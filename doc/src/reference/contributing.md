# Contributing

Thank you for considering contributing to nix-shell-templates!

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sibeov/nix-shell-templates.git
   cd nix-shell-templates
   ```

2. **Enter the development shell**:
   ```bash
   nix develop
   ```

3. **Available commands**:
   - `fmt` - Format Nix files
   - `check` - Run flake check
   - `doc-serve` - Serve documentation locally
   - `doc-build` - Build documentation

## Development Workflow

### Making Changes

1. Create a branch for your changes
2. Make your modifications
3. Format code: `fmt`
4. Run checks: `check`
5. Test your changes

### Testing Modules

Test a module by enabling it in the main flake:

```bash
# In flake.nix, temporarily enable the module
# templates.rust.enable = true;

# Then enter that shell
nix develop .#rust
```

### Testing Templates

```bash
# Create a test directory
mkdir /tmp/test-template && cd /tmp/test-template

# Initialize with your local template
nix flake init -t path:/home/user/nix-shell-templates#rust

# Test it
nix develop
```

## Code Style

### Nix Formatting

Use the official Nix formatter (RFC 166):

```bash
nixfmt .
# or
nix fmt
```

### Module Structure

Follow this pattern for new modules:

```nix
# Module description
#
# What this module provides.
{ lib, config, ... }:
let
  cfg = config.templates.moduleName;
in
{
  options.templates.moduleName = {
    enable = lib.mkEnableOption "Module description";
    
    # Group related options
    someOption = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "What this option does";
    };
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

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) with [cocogitto](https://docs.cocogitto.io/):

```
type(scope): description

[optional body]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `build` - Build system changes
- `refactor` - Code refactoring
- `test` - Tests
- `chore` - Maintenance

Examples:
```
feat(rust): add support for cargo-criterion
fix(python): correct venv activation on zsh
docs(modules): add rust cross-compilation example
build(flake.nix): update nixpkgs input
```

## Adding a New Module

1. **Create the module file** in `modules/`:
   ```nix
   # modules/newlang.nix
   { lib, config, ... }:
   let cfg = config.templates.newlang;
   in {
     options.templates.newlang = { ... };
     config = lib.mkIf cfg.enable { ... };
   }
   ```

2. **Register in flake.nix**:
   ```nix
   flakeModules = {
     # ...existing modules...
     newlang = ./modules/newlang.nix;
   };
   
   imports = [
     # ...existing imports...
     flakeModules.newlang
   ];
   ```

3. **Create a template** in `templates/newlang/flake.nix`

4. **Add template definition** in flake.nix:
   ```nix
   templates.newlang = {
     path = ./templates/newlang;
     description = "New language development environment";
   };
   ```

5. **Add container support** in `containers/flake-module.nix` (optional)

6. **Document** in `doc/src/modules/newlang.md`

7. **Update SUMMARY.md** to include the new documentation

## Documentation

### Building Docs

```bash
doc-build    # Build to doc/book/
doc-serve    # Serve at http://localhost:3000
```

### Documentation Style

- Use clear, concise language
- Include code examples
- Document all options with type, default, and description
- Add practical configuration examples

## Pull Request Guidelines

1. **One feature per PR**: Keep changes focused
2. **Update documentation**: If adding features, document them
3. **Test on multiple platforms**: If possible, test on Linux and macOS
4. **Follow commit conventions**: Use conventional commits
5. **Describe your changes**: Explain what and why in the PR description

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
