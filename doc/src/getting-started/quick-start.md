# Quick Start

This guide walks you through creating a development environment in under a minute.

## Using a Template

The fastest way to get started is using one of the pre-configured templates.

### Rust Project

```bash
mkdir my-rust-project && cd my-rust-project
nix flake init -t github:sibeov/nix-shell-templates#rust
nix develop
```

You now have:
- Rust toolchain from `rust-toolchain.toml` (works with rustup too)
- rust-analyzer, clippy, rustfmt, rust-src
- cargo-watch, cargo-edit, cargo-audit, cargo-nextest
- `Cargo.toml` ready to build

### Python Project

```bash
mkdir my-python-project && cd my-python-project
nix flake init -t github:sibeov/nix-shell-templates#python
nix develop
```

You now have:
- Python 3.12
- uv (fast package manager)
- ruff, mypy
- Automatic virtualenv creation

### FPGA Project

```bash
mkdir my-fpga-project && cd my-fpga-project
nix flake init -t github:sibeov/nix-shell-templates#fpga
nix develop
```

You now have:
- OSS CAD Suite (Yosys, nextpnr, icestorm)
- GTKWave
- Verilator

### Typst Documents

```bash
mkdir my-document && cd my-document
nix flake init -t github:sibeov/nix-shell-templates#typst
nix develop
```

You now have:
- Typst compiler
- Typst LSP and tinymist
- PDF viewer (zathura)
- Common fonts

## Using with direnv

For automatic environment activation, create `.envrc`:

```bash
echo "use flake" > .envrc
direnv allow
```

Now the environment activates automatically when you enter the directory.

## Available Commands

The Rust template shows available commands on shell entry:

```bash
$ nix develop
Rust Development Environment
Toolchain: rustc 1.85.0 (stable)

Available commands:
  cargo build    - Build the project
  cargo test     - Run tests
  cargo clippy   - Run linter
  cargo fmt      - Format code
  cargo watch    - Watch for changes
```

## Next Steps

- [Customize your environment](../templates/customization.md)
- [Learn about modules](../modules/common.md)
- [Understand the project structure](./project-structure.md)
