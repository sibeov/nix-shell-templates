# Rust Module

Provides a Rust development environment using [rust-overlay](https://github.com/oxalica/rust-overlay).

## Features

- **Toolchain from file**: Reads `rust-toolchain.toml` for rustup compatibility
- **Cross-environment**: Same toolchain for Nix and non-Nix users
- **Cargo tools**: Common utilities pre-installed
- **Complete scaffold**: Template includes `Cargo.toml` ready to build

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#rust
nix develop
```

The template creates:
- `flake.nix` - Nix development environment
- `rust-toolchain.toml` - Toolchain specification (works with rustup too)
- `Cargo.toml` - Project manifest

## rust-toolchain.toml

The toolchain is defined in `rust-toolchain.toml`, which is read by both Nix (via `rust-bin.fromRustupToolchainFile`) and rustup:

```toml
[toolchain]
channel = "stable"
profile = "default"
components = [
    "rust-src",
    "clippy",
    "rustfmt",
    "rust-analyzer",
]
```

### Customizing the Toolchain

Edit `rust-toolchain.toml` to change:

**Use nightly:**
```toml
[toolchain]
channel = "nightly"
```

**Pin to specific version:**
```toml
[toolchain]
channel = "1.85.0"
```

**Add cross-compilation targets:**
```toml
[toolchain]
channel = "stable"
targets = ["wasm32-unknown-unknown", "aarch64-unknown-linux-gnu"]
```

## Module Options

When using the module (for advanced use cases):

### `templates.rust.enable`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable the Rust development environment.

### `templates.rust.toolchainFile`

| Property | Value |
|----------|-------|
| Type | `path` |
| Required | Yes |

Path to `rust-toolchain.toml` file. This file is read by both Nix and rustup.

```nix
templates.rust = {
  enable = true;
  toolchainFile = ./rust-toolchain.toml;
};
```

### `templates.rust.edition`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"2024"` |

Rust edition for new projects created with the `new-project` command.

### `templates.rust.includeCargoTools`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include common cargo tools (cargo-watch, cargo-edit, cargo-audit, cargo-outdated, cargo-nextest).

### `templates.rust.extraPackages`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Additional Nix packages to include.

## Shell Commands

| Command | Description |
|---------|-------------|
| `rust-info` | Show Rust toolchain version information |
| `new-project <name>` | Create a new Rust project with configured edition |
| `check-all` | Run cargo check, clippy, and fmt |
| `watch` | Watch for changes and run cargo check |

## Environment Variables

| Variable | Value |
|----------|-------|
| `RUST_BACKTRACE` | `1` |
| `CARGO_TERM_COLOR` | `always` |

## Cargo.toml

The template includes a `Cargo.toml` with sensible defaults:

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2024"

[lints.rust]
unsafe_code = "forbid"

[lints.clippy]
all = { level = "warn", priority = -1 }
pedantic = { level = "warn", priority = -1 }
nursery = { level = "warn", priority = -1 }
```

**Note:** Rename `my-project` to your actual project name.

## Included Cargo Tools

When `includeCargoTools = true`:

| Tool | Description |
|------|-------------|
| `cargo-watch` | Watch for changes and run commands |
| `cargo-edit` | Add/remove/upgrade dependencies |
| `cargo-audit` | Audit dependencies for vulnerabilities |
| `cargo-outdated` | Find outdated dependencies |
| `cargo-nextest` | Next-generation test runner |

## Non-Nix Usage

The `rust-toolchain.toml` file works with rustup:

```bash
# Without Nix, rustup reads rust-toolchain.toml automatically
rustup show  # Shows active toolchain
cargo build  # Uses toolchain from file
```

This ensures your team can use the same toolchain regardless of whether they use Nix.

## Exported Packages

| Package | Description |
|---------|-------------|
| `packages.rust-toolchain` | The configured Rust toolchain |
