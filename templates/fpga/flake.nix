# FPGA Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#fpga
#
# A standalone FPGA development environment using:
# - oss-cad-suite.nix: OSS CAD Suite package definition (edit to change version)
#
# This template is self-contained: all configuration is in this directory.
# Edit oss-cad-suite.nix to update the toolchain version.
{
  description = "FPGA development environment with OSS CAD Suite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      # Supported systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Helper to generate per-system attributes
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Build oss-cad-suite from local file
          oss-cad-suite = pkgs.callPackage ./oss-cad-suite.nix {
            inherit system;
          };

          # Optional additional tools
          extraTools = [
            pkgs.gtkwave # Waveform viewer
            pkgs.verilator # Verilog simulator
          ];
        in
        {
          default = pkgs.mkShell {
            name = "fpga-dev";

            packages = [ oss-cad-suite ] ++ extraTools;

            env = {
              OSS_CAD_SUITE_ROOT = "${oss-cad-suite}";
            };

            shellHook = ''
              echo ""
              echo "FPGA Development Environment"
              echo "============================="
              echo "OSS CAD Suite: ${oss-cad-suite.version}"
              echo ""
              echo "Tools available:"
              echo "  yosys       - Synthesis"
              echo "  nextpnr-*   - Place and route"
              echo "  icepack     - iCE40 bitstream"
              echo "  ecppack     - ECP5 bitstream"
              echo "  gtkwave     - Waveform viewer"
              echo "  verilator   - Verilog simulator"
              echo ""
              echo "To update the toolchain, edit oss-cad-suite.nix"
              echo ""
            '';
          };
        }
      );

      # Export the oss-cad-suite package
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          oss-cad-suite = pkgs.callPackage ./oss-cad-suite.nix {
            inherit system;
          };
          default = pkgs.callPackage ./oss-cad-suite.nix {
            inherit system;
          };
        }
      );
    };
}
