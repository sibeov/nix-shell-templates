# Architecture

Understanding the internal architecture helps when extending or debugging.

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Flake framework | [flake-parts](https://flake.parts) | Modular flake composition |
| Development shells | [numtide/devshell](https://github.com/numtide/devshell) | Rich shell environments |
| Container building | [nix2container](https://github.com/nlewo/nix2container) | OCI image generation |
| Rust toolchains | [rust-overlay](https://github.com/oxalica/rust-overlay) | Flexible Rust versions |
| Packages | [nixpkgs](https://github.com/NixOS/nixpkgs) | Package repository |

## Module System

### Option Namespace

All options live under the `templates` namespace:

```
templates
├── projectName          # Common
├── projectDescription   # Common
├── commonPackages       # Common
├── debug                # Common
├── fpga                 # FPGA module
│   ├── enable
│   ├── version
│   └── ...
├── rust                 # Rust module
│   ├── enable
│   ├── channel
│   └── ...
├── python               # Python module
│   └── ...
├── typst                # Typst module
│   └── ...
└── containers           # Container module
    └── ...
```

### Module Lifecycle

1. **Option declaration**: Module declares options in `options.templates.moduleName`
2. **Evaluation**: User sets option values in their flake
3. **Configuration**: `config = lib.mkIf cfg.enable { ... }` applies when enabled
4. **Output generation**: perSystem creates devshells and packages

### Data Flow

```
User flake.nix
      │
      ▼
┌─────────────────────────────────────┐
│         flake-parts.lib.mkFlake     │
│                                     │
│  ┌─────────────┐  ┌──────────────┐  │
│  │ common.nix  │  │  rust.nix    │  │
│  │ (options)   │  │  (options)   │  │
│  └──────┬──────┘  └──────┬───────┘  │
│         │                │          │
│         ▼                ▼          │
│  ┌─────────────────────────────┐    │
│  │      Module Evaluation      │    │
│  │   (merge options & config)  │    │
│  └──────────────┬──────────────┘    │
│                 │                   │
│                 ▼                   │
│  ┌─────────────────────────────┐    │
│  │        perSystem            │    │
│  │  ┌──────────────────────┐   │    │
│  │  │   devshells.rust     │   │    │
│  │  │   packages.*         │   │    │
│  │  └──────────────────────┘   │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
      │
      ▼
Flake outputs (devShells, packages, ...)
```

## Devshell Structure

Each module creates a devshell with:

```nix
devshells.moduleName = {
  name = "module-dev";
  
  # Welcome message
  motd = ''...'';
  
  # Nix packages
  packages = [ ... ];
  
  # Environment variables
  env = [ { name = "VAR"; value = "val"; } ];
  
  # Shell commands (shown in menu)
  commands = [
    {
      name = "cmd";
      help = "description";
      command = "script...";
      category = "optional-category";
    }
  ];
  
  # Startup scripts
  devshell.startup.name.text = ''...'';
};
```

## Container Architecture

Containers mirror devshells but without interactive features:

```
┌────────────────────────────────────┐
│           Container Image          │
│                                    │
│  ┌──────────────────────────────┐  │
│  │       /nix/store/...        │  │  ← Nix packages (layers)
│  │  ┌────────────────────────┐  │  │
│  │  │ Tool binaries          │  │  │
│  │  │ Libraries              │  │  │
│  │  │ Fonts (typst)          │  │  │
│  │  └────────────────────────┘  │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │       Environment           │  │
│  │  RUST_BACKTRACE=1           │  │
│  │  PYTHONUNBUFFERED=1         │  │
│  └──────────────────────────────┘  │
│                                    │
│  Entrypoint: /bin/bash             │
└────────────────────────────────────┘
```

## Input Dependencies

```
                  nixpkgs
                     │
    ┌────────────────┼────────────────┐
    │                │                │
    ▼                ▼                ▼
flake-parts     devshell      rust-overlay
    │                │                │
    └────────────────┼────────────────┘
                     │
                     ▼
           nix-shell-templates
                     │
                     ▼
              nix2container
```

All inputs follow nixpkgs to ensure compatibility.

## File Layout

```
nix-shell-templates/
├── flake.nix           # Entry point, defines inputs and imports
├── flake.lock          # Pinned dependency versions
├── modules/
│   ├── common.nix      # Shared options (no devshell)
│   ├── fpga.nix        # Creates devshells.fpga
│   ├── rust.nix        # Creates devshells.rust
│   ├── python.nix      # Creates devshells.python
│   └── typst.nix       # Creates devshells.typst
├── containers/
│   └── flake-module.nix  # Creates packages.container-*
├── templates/
│   ├── default/flake.nix # Template with all modules
│   ├── rust/flake.nix    # Rust-only template
│   └── ...
└── doc/                  # This documentation
```
