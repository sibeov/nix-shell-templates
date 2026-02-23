# Containers Module

Build OCI-compliant container images that mirror your development environment using [nix2container](https://github.com/nlewo/nix2container).

## Features

- **Automatic image generation**: Containers built for each enabled module
- **Reproducible**: Exact same tools as your dev environment
- **Efficient**: Layered images with Nix store deduplication
- **OCI compliant**: Works with Docker, Podman, containerd

## Quick Start

Enable containers alongside your development modules:

```nix
templates.rust.enable = true;
templates.containers.enable = true;
```

Then build:

```bash
nix build .#container-rust
```

## Options

### `templates.containers.enable`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable OCI container image building.

### `templates.containers.registry`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"localhost:5000"` |

Default container registry for push operations.

### `templates.containers.imagePrefix`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"nix-shell-templates"` |

Prefix for container image names.

### `templates.containers.tag`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"latest"` |

Tag for container images.

## Available Containers

When enabled, containers are built for each enabled module:

| Package | Module Required | Description |
|---------|-----------------|-------------|
| `container-fpga` | `templates.fpga.enable` | FPGA tools container |
| `container-rust` | `templates.rust.enable` | Rust toolchain container |
| `container-python` | `templates.python.enable` | Python environment container |
| `container-typst` | `templates.typst.enable` | Typst compiler container |

## Building Images

```bash
# Build specific container
nix build .#container-rust

# Load into Docker
docker load < result

# Or stream directly
nix build .#container-rust --json | jq -r '.[0].outputs.out' | docker load
```

## Image Contents

Each container includes:

- Tools from the corresponding module
- bash (for shell access)
- coreutils (basic utilities)
- Labels for OCI compliance

## Example Configuration

```nix
{
  # Enable modules
  templates.rust = {
    enable = true;
    channel = "stable";
    includeCargoTools = true;
  };
  
  templates.python = {
    enable = true;
    pythonVersion = "python312";
    useUv = true;
  };
  
  # Enable containers for both
  templates.containers = {
    enable = true;
    imagePrefix = "myorg";
    tag = "v1.0.0";
  };
}
```

This creates:
- `myorg/rust:v1.0.0`
- `myorg/python:v1.0.0`

## CI/CD Usage

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v24
      - name: Build container
        run: nix build .#container-rust
      - name: Push to registry
        run: |
          docker load < result
          docker push myorg/rust:latest
```

### GitLab CI

```yaml
build:
  image: nixos/nix:latest
  script:
    - nix build .#container-rust
    - docker load < result
    - docker push $CI_REGISTRY_IMAGE/rust:$CI_COMMIT_TAG
```

## Why nix2container?

nix2container creates optimized OCI images:

1. **Layer deduplication**: Nix store paths become layers
2. **Caching**: Unchanged layers are reused
3. **No Docker daemon**: Build without Docker
4. **Reproducibility**: Same inputs = identical image

## Limitations

- Container images don't include the development shell MOTD or commands
- Some tools may require additional runtime configuration
- GUI applications (GTKWave, zathura) need X11 forwarding in container
