# nix-shell-templates

Modular Nix development environments using [flake-parts](https://flake.parts).

## Overview

**nix-shell-templates** provides ready-to-use development environment templates for various programming languages and tools. Built on top of [numtide/devshell](https://github.com/numtide/devshell) and [flake-parts](https://github.com/hercules-ci/flake-parts), it offers:

- **Modular design**: Enable only the modules you need
- **Reproducible environments**: Same tools, same versions, everywhere
- **Container support**: Build OCI containers matching your dev environment
- **Easy customization**: Override any option to fit your needs

## Available Modules

| Module | Description |
|--------|-------------|
| [FPGA](./modules/fpga.md) | FPGA development with oss-cad-suite (Yosys, nextpnr, icestorm) |
| [Rust](./modules/rust.md) | Rust toolchain with rust-overlay (stable/beta/nightly) |
| [Python](./modules/python.md) | Python development with uv, virtualenv, ruff, mypy |
| [Typst](./modules/typst.md) | Typst document development with LSP and fonts |
| [Containers](./modules/containers.md) | OCI container images via nix2container |

## Quick Example

```bash
# Initialize a new Rust project
mkdir my-rust-project && cd my-rust-project
nix flake init -t github:sibeov/nix-shell-templates#rust

# Enter the development environment
nix develop

# You now have rustc, cargo, rust-analyzer, clippy, and more!
```

## Requirements

- [Nix](https://nixos.org/download.html) with flakes enabled
- Recommended: [direnv](https://direnv.net/) for automatic environment activation

## License

This project is open source. See the repository for license details.
