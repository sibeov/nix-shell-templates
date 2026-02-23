# Rust Module

Provides a modern Rust development environment using [rust-overlay](https://github.com/oxalica/rust-overlay).

## Features

- **Flexible toolchain**: stable, beta, or nightly channels
- **Version pinning**: Lock to specific Rust versions
- **Components**: rust-analyzer, clippy, rustfmt included by default
- **Cross-compilation**: Add targets for WASM, ARM, etc.
- **Cargo tools**: Common utilities pre-installed

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#rust
nix develop
```

## Options

### `templates.rust.enable`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable the Rust development environment.

### `templates.rust.channel`

| Property | Value |
|----------|-------|
| Type | `enum: "stable"`, `"beta"`, `"nightly"` |
| Default | `"stable"` |

Rust toolchain channel.

### `templates.rust.version`

| Property | Value |
|----------|-------|
| Type | `null` or `string` |
| Default | `null` |
| Example | `"1.75.0"` |

Specific Rust version. If null, uses latest from channel.

### `templates.rust.edition`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"2024"` |

Rust edition for new projects.

### `templates.rust.components`

| Property | Value |
|----------|-------|
| Type | `list of string` |
| Default | `["rustfmt", "clippy", "rust-analyzer"]` |

Rust components to include.

### `templates.rust.targets`

| Property | Value |
|----------|-------|
| Type | `list of string` |
| Default | `[]` |
| Example | `["wasm32-unknown-unknown", "aarch64-unknown-linux-gnu"]` |

Additional compilation targets for cross-compilation.

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

## Example Configurations

### Stable with defaults

```nix
templates.rust = {
  enable = true;
};
```

### Nightly with WASM target

```nix
templates.rust = {
  enable = true;
  channel = "nightly";
  targets = [ "wasm32-unknown-unknown" ];
  extraPackages = with pkgs; [
    wasm-pack
    wasm-bindgen-cli
  ];
};
```

### Pinned version

```nix
templates.rust = {
  enable = true;
  channel = "stable";
  version = "1.75.0";
};
```

### Minimal setup

```nix
templates.rust = {
  enable = true;
  components = [ "rustfmt" ];  # No clippy or rust-analyzer
  includeCargoTools = false;   # No cargo-* tools
};
```

## Included Cargo Tools

When `includeCargoTools = true`:

| Tool | Description |
|------|-------------|
| `cargo-watch` | Watch for changes and run commands |
| `cargo-edit` | Add/remove/upgrade dependencies |
| `cargo-audit` | Audit dependencies for vulnerabilities |
| `cargo-outdated` | Find outdated dependencies |
| `cargo-nextest` | Next-generation test runner |

## Exported Packages

| Package | Description |
|---------|-------------|
| `packages.rust-toolchain` | The configured Rust toolchain |
