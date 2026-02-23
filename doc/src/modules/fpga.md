# FPGA Module

Provides a complete FPGA development environment using [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build).

## Philosophy

This module is designed to be **self-contained**. The toolchain configuration lives in a standard Nix file that's part of your project:

| File | Purpose |
|------|---------|
| `oss-cad-suite.nix` | OSS CAD Suite package with version and hashes |

Edit this file to update to a newer release or add platform support.

## Features

- **Self-contained**: `oss-cad-suite.nix` is part of your project
- **OSS CAD Suite**: Yosys, nextpnr, icestorm, Amaranth, and more
- **Waveform viewing**: GTKWave (optional)
- **Simulation**: Verilator (optional)

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#fpga
nix develop
```

This creates:
- `flake.nix` - Standalone Nix flake
- `oss-cad-suite.nix` - OSS CAD Suite package definition

## Configuration File

### oss-cad-suite.nix

The package definition with version configuration:

```nix
{
  lib, stdenv, fetchurl, autoPatchelfHook,
  zlib, libxcrypt-legacy, python3, bash, system,
}:

let
  # ===========================================
  # VERSION CONFIGURATION
  # ===========================================
  version = "2026-01-26";
  dateVersion = "20260126";

  # ===========================================
  # SHA256 HASHES PER PLATFORM
  # ===========================================
  sources = {
    x86_64-linux = {
      url = "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${version}/oss-cad-suite-linux-x64-${dateVersion}.tgz";
      sha256 = "sha256-jkei60pexQ52rfwWr1bD4e+nlw9LWd8gt2y6fDtQvYw=";
    };
    # ... other platforms
  };
in
stdenv.mkDerivation {
  pname = "oss-cad-suite";
  inherit version;
  # ...
}
```

## Updating the Version

1. Find the latest release at [YosysHQ/oss-cad-suite-build](https://github.com/YosysHQ/oss-cad-suite-build/releases)

2. Update `oss-cad-suite.nix`:
   ```nix
   version = "2026-02-15";      # New release date
   dateVersion = "20260215";    # Same date, no dashes
   ```

3. Get the new hash:
   ```bash
   nix-prefetch-url --unpack https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-02-15/oss-cad-suite-linux-x64-20260215.tgz
   ```

4. Update the sha256 in `sources.x86_64-linux`

5. Re-enter the shell:
   ```bash
   exit
   nix develop
   ```

## Using the Module

If using the flake module system (instead of the standalone template):

```nix
{
  imports = [
    nix-shell-templates.flakeModules.fpga
  ];

  templates.fpga = {
    enable = true;
    ossCadSuiteFile = ./oss-cad-suite.nix;  # Required
  };
}
```

### Module Options

#### `templates.fpga.ossCadSuiteFile`

| Property | Value |
|----------|-------|
| Type | `path` |
| Required | Yes |

Path to `oss-cad-suite.nix` file containing the package definition.

#### `templates.fpga.includeGtkwave`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include GTKWave for waveform viewing.

#### `templates.fpga.includeVerilator`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include Verilator for Verilog simulation.

#### `templates.fpga.extraPackages`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Additional Nix packages to include.

## Shell Commands

| Command | Description |
|---------|-------------|
| `fpga-info` | Show FPGA toolchain version information |
| `synth` | Run Yosys synthesis |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `OSS_CAD_SUITE_ROOT` | Path to the OSS CAD Suite installation |

## Included Tools

OSS CAD Suite provides:

| Category | Tools |
|----------|-------|
| **Synthesis** | Yosys |
| **Place & Route** | nextpnr (ice40, ecp5, gowin, himbaechel) |
| **Bitstream** | icestorm, prjtrellis, prjoxide |
| **Simulation** | Verilator, Icarus Verilog, GHDL |
| **Formal** | sby (SymbiYosys) |
| **Python HDL** | Amaranth, Migen |

## Platform Support

| Platform | Status |
|----------|--------|
| x86_64-linux | Fully supported (hash included) |
| aarch64-linux | Add sha256 hash to `oss-cad-suite.nix` |
| x86_64-darwin | Add sha256 hash to `oss-cad-suite.nix` |
| aarch64-darwin | Add sha256 hash to `oss-cad-suite.nix` |

### Adding Platform Support

1. Get the hash for your platform:
   ```bash
   nix-prefetch-url --unpack <url-for-your-platform>
   ```

2. Add it to `oss-cad-suite.nix`:
   ```nix
   aarch64-darwin = {
     url = "...";
     sha256 = "sha256-YOUR_HASH_HERE";
   };
   ```

## Example: iCE40 Project

```bash
# Create project
nix flake init -t github:sibeov/nix-shell-templates#fpga
nix develop

# Synthesize
yosys -p "synth_ice40 -top top -json top.json" top.v

# Place and route
nextpnr-ice40 --hx8k --package ct256 --json top.json --asc top.asc

# Generate bitstream
icepack top.asc top.bin

# Program (if using iceprog)
iceprog top.bin
```

## Why This Approach?

### Self-Contained Projects

Your `oss-cad-suite.nix` is part of your project, so:
- Version is pinned and reproducible
- No external dependencies on nix-shell-templates for the package
- Team members get the exact same toolchain
- Easy to update without waiting for upstream

### Easy Version Management

Unlike downloading binaries manually:
- Nix handles caching and storage
- Multiple projects can use different versions
- Rollback is trivial (just revert the file)
