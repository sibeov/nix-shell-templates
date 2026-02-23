# FPGA Module

Provides a complete FPGA development environment using [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build).

## Features

- **OSS CAD Suite**: Yosys, nextpnr, icestorm, Amaranth, and more
- **Waveform viewing**: GTKWave (optional)
- **Simulation**: Verilator (optional)
- **Configurable versions**: Pin to specific releases

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#fpga
nix develop
```

## Options

### `templates.fpga.enable`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable the FPGA development environment.

### `templates.fpga.version`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"2026-01-26"` |

OSS CAD Suite release version in date format (YYYY-MM-DD).

### `templates.fpga.dateVersion`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"20260126"` |

OSS CAD Suite date version for download URL (YYYYMMDD format).

### `templates.fpga.includeGtkwave`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include GTKWave for waveform viewing.

### `templates.fpga.includeVerilator`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include Verilator for Verilog simulation.

### `templates.fpga.extraPackages`

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

## Example Configuration

```nix
templates.fpga = {
  enable = true;
  version = "2026-01-26";
  dateVersion = "20260126";
  includeGtkwave = true;
  includeVerilator = true;
  extraPackages = with pkgs; [
    python3
    gnumake
  ];
};
```

## Included Tools

OSS CAD Suite provides:

- **Synthesis**: Yosys
- **Place & Route**: nextpnr (ice40, ecp5, gowin, himbaechel)
- **Bitstream tools**: icestorm, prjtrellis, prjoxide
- **Simulation**: Verilator, Icarus Verilog, GHDL
- **Formal verification**: sby (SymbiYosys)
- **Python HDL**: Amaranth, Migen

## Platform Support

| Platform | Status |
|----------|--------|
| x86_64-linux | Fully supported |
| aarch64-linux | Requires sha256 hash |
| x86_64-darwin | Requires sha256 hash |
| aarch64-darwin | Requires sha256 hash |

> **Note**: Non-x86_64-linux platforms require adding the appropriate sha256 hash to `templates/oss-cad-suite.nix`.
