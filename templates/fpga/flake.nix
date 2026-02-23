# FPGA Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#fpga
#
# Provides a complete FPGA development environment with:
# - OSS CAD Suite (Yosys, nextpnr, icestorm, etc.)
# - GTKWave for waveform viewing
# - Verilator for simulation
{
  description = "FPGA development environment with oss-cad-suite";

  inputs = {
    nix-shell-templates.url = "github:sibeov/nix-shell-templates";
    nixpkgs.follows = "nix-shell-templates/nixpkgs";
    flake-parts.follows = "nix-shell-templates/flake-parts";
    devshell.follows = "nix-shell-templates/devshell";
  };

  outputs =
    inputs@{
      self,
      nix-shell-templates,
      nixpkgs,
      flake-parts,
      devshell,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devshell.flakeModule
        nix-shell-templates.flakeModules.common
        nix-shell-templates.flakeModules.fpga
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Project configuration
      templates.projectName = "fpga-project";

      # FPGA module configuration
      templates.fpga = {
        enable = true;

        # OSS CAD Suite version
        # Update these to use a newer release
        version = "2026-01-26";
        dateVersion = "20260126";

        # Tool options
        includeGtkwave = true;
        includeVerilator = true;

        # Add any extra packages you need
        extraPackages = [ ];
      };

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          # Default formatter
          formatter = pkgs.alejandra;

          # Make the FPGA shell the default
          devShells.default = config.devShells.fpga;
        };
    };
}
