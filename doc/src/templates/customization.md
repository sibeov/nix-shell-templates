# Customization

Templates provide sensible defaults, but you can customize everything.

## Common Customizations

### Change Project Name

```nix
templates.projectName = "my-awesome-project";
```

### Add Global Packages

Packages available in all enabled shells:

```nix
templates.commonPackages = with pkgs; [
  git
  gh
  just
  watchexec
];
```

### Rust: Use Nightly

```nix
templates.rust = {
  enable = true;
  channel = "nightly";
};
```

### Rust: Add WASM Target

```nix
templates.rust = {
  enable = true;
  targets = [ "wasm32-unknown-unknown" ];
  extraPackages = with pkgs; [
    wasm-pack
    wasm-bindgen-cli
  ];
};
```

### Python: Different Version

```nix
templates.python = {
  enable = true;
  pythonVersion = "python313";  # Latest Python
};
```

### Python: Use pip Instead of uv

```nix
templates.python = {
  enable = true;
  useUv = false;
};
```

### Add Custom Shell Commands

Extend the devshell with your own commands:

```nix
perSystem = { config, pkgs, ... }: {
  devshells.rust = {
    commands = [
      {
        name = "deploy";
        help = "Deploy to production";
        command = "cargo build --release && ./scripts/deploy.sh";
      }
    ];
  };
};
```

### Add Environment Variables

```nix
perSystem = { config, pkgs, ... }: {
  devshells.python = {
    env = [
      { name = "DATABASE_URL"; value = "postgresql://localhost/dev"; }
      { name = "DEBUG"; value = "1"; }
    ];
  };
};
```

## Advanced Customization

### Custom Package Overlays

```nix
perSystem = { system, ... }: {
  _module.args.pkgs = import nixpkgs {
    inherit system;
    overlays = [
      rust-overlay.overlays.default
      (final: prev: {
        # Your custom packages
        my-tool = prev.callPackage ./my-tool.nix {};
      })
    ];
  };
};
```

### Override Module Defaults

You can override any module option:

```nix
templates.rust = {
  enable = true;
  components = [
    "rustfmt"
    "clippy"
    "rust-analyzer"
    "rust-src"        # Add for IDE support
    "llvm-tools"      # Add for coverage
  ];
};
```

### Combine with Other Flake-Parts Modules

```nix
{
  inputs = {
    nix-shell-templates.url = "github:sibeov/nix-shell-templates";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nix-shell-templates.flakeModules.rust
      ];

      perSystem = { ... }: {
        treefmt.programs = {
          nixfmt.enable = true;
          rustfmt.enable = true;
        };
      };
    };
}
```

### Create Your Own Module

Extend with a project-specific module:

```nix
# my-module.nix
{ lib, config, ... }: {
  options.myProject = {
    enableAuth = lib.mkEnableOption "authentication features";
  };

  config = lib.mkIf config.myProject.enableAuth {
    perSystem = { pkgs, ... }: {
      devshells.default = {
        packages = [ pkgs.openssl ];
        env = [{ name = "AUTH_ENABLED"; value = "1"; }];
      };
    };
  };
}
```

Then import it:

```nix
imports = [
  ./my-module.nix
  nix-shell-templates.flakeModules.rust
];

myProject.enableAuth = true;
```

## Debugging

Enable debug mode for verbose output:

```nix
templates.debug = true;
```

Check what's being built:

```bash
# Show flake outputs
nix flake show

# Show devshell packages
nix develop --command printenv | grep PATH

# Dry-run build
nix build .#devShells.x86_64-linux.rust --dry-run
```

## Tips

1. **Start simple**: Use defaults first, customize as needed
2. **Use extraPackages**: Add tools without modifying module internals
3. **Pin versions**: Use `flake.lock` for reproducibility
4. **Document changes**: Comment your customizations in `flake.nix`
