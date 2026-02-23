# Installation

## Prerequisites

### Nix with Flakes

nix-shell-templates requires Nix with flakes enabled. If you don't have Nix installed:

```bash
# Install Nix (multi-user installation recommended)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or use the official installer:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Enable Flakes

If you used the Determinate Systems installer, flakes are already enabled. Otherwise, add to `~/.config/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

### Optional: direnv

For automatic environment activation when entering project directories:

```bash
# Install direnv (via your package manager or Nix)
nix profile install nixpkgs#direnv

# Add to your shell config (~/.bashrc, ~/.zshrc, etc.)
eval "$(direnv hook bash)"  # or zsh, fish, etc.
```

## Verify Installation

```bash
# Check Nix version (should be 2.4+)
nix --version

# Check flakes are enabled
nix flake --help
```

## Next Steps

Continue to [Quick Start](./quick-start.md) to create your first development environment.
