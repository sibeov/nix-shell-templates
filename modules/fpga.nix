# FPGA development module
#
# Provides a complete FPGA development environment using oss-cad-suite.
# Includes: Yosys, nextpnr, icestorm, and related tools.
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates.fpga;
in
{
  options.templates.fpga = {
    enable = lib.mkEnableOption "FPGA development environment";

    # OSS CAD Suite version configuration
    version = lib.mkOption {
      type = lib.types.str;
      default = "2026-01-26";
      description = "OSS CAD Suite release version (date format: YYYY-MM-DD)";
    };

    dateVersion = lib.mkOption {
      type = lib.types.str;
      default = "20260126";
      description = "OSS CAD Suite date version for URL (format: YYYYMMDD)";
    };

    # Additional packages to include
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to include in the FPGA development shell";
    };

    # GTKWave for waveform viewing
    includeGtkwave = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include GTKWave for waveform viewing";
    };

    # Verilator for Verilog simulation
    includeVerilator = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Verilator for Verilog simulation";
    };
  };

  config = lib.mkIf cfg.enable {
    perSystem =
      {
        pkgs,
        system,
        ...
      }:
      let
        # Build oss-cad-suite package with configured version
        oss-cad-suite = pkgs.callPackage ../templates/oss-cad-suite.nix {
          inherit system;
          version = cfg.version;
          dateVersion = cfg.dateVersion;
        };

        # Collect all FPGA-related packages
        fpgaPackages = [
          oss-cad-suite
        ]
        ++ lib.optionals cfg.includeGtkwave [ pkgs.gtkwave ]
        ++ lib.optionals cfg.includeVerilator [ pkgs.verilator ]
        ++ cfg.extraPackages
        ++ config.templates.commonPackages;
      in
      {
        # Export the oss-cad-suite package
        packages.oss-cad-suite = oss-cad-suite;

        # Development shell using devshell
        devshells.fpga = {
          name = "fpga-dev";
          motd = ''
            {202}FPGA Development Environment{reset}
            {bold}OSS CAD Suite ${cfg.version}{reset}

            Tools available: yosys, nextpnr, icestorm, and more
            $(type -p menu &>/dev/null && menu)
          '';

          packages = fpgaPackages;

          env = [
            {
              name = "OSS_CAD_SUITE_ROOT";
              value = "${oss-cad-suite}";
            }
          ];

          commands = [
            {
              name = "fpga-info";
              help = "Show FPGA toolchain information";
              command = ''
                echo "OSS CAD Suite: ${cfg.version}"
                echo "Yosys: $(yosys --version 2>/dev/null || echo 'not found')"
                echo "nextpnr: $(nextpnr-ice40 --version 2>/dev/null || echo 'not found')"
              '';
            }
            {
              name = "synth";
              help = "Run Yosys synthesis";
              command = "yosys \"$@\"";
            }
          ];
        };
      };
  };
}
