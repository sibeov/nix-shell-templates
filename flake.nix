{
  description = "Nix shell templates using flake-parts - modular development environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Development shell framework
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OCI container image builder
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchain overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      devshell,
      nix2container,
      rust-overlay,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        withSystem,
        flake-parts-lib,
        ...
      }:
      let
        # Define flake modules that can be imported by other flakes
        # These are defined in a let binding so they can be both:
        # 1. Exported via flake.flakeModules
        # 2. Imported locally via imports
        flakeModules = {
          common = ./modules/common.nix;
          fpga = ./modules/fpga.nix;
          rust = ./modules/rust.nix;
          python = ./modules/python.nix;
          typst = ./modules/typst.nix;
          containers = ./containers/flake-module.nix;
        };
      in
      {
        imports = [
          inputs.devshell.flakeModule
          flakeModules.common
          flakeModules.fpga
          flakeModules.rust
          flakeModules.python
          flakeModules.typst
          flakeModules.containers
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        # Export the flake modules for use by other flakes
        flake = {
          inherit flakeModules;

          # Template definitions for `nix flake init -t`
          templates = {
            default = {
              path = ./templates/default;
              description = "Default template with all modules (enable manually)";
            };
            fpga = {
              path = ./templates/fpga;
              description = "FPGA development environment with oss-cad-suite";
            };
            rust = {
              path = ./templates/rust;
              description = "Rust development environment";
            };
            python = {
              path = ./templates/python;
              description = "Python development environment";
            };
            typst = {
              path = ./templates/typst;
              description = "Typst document development environment";
            };
          };
        };

        # Per-system configuration for this flake itself (development/testing)
        perSystem =
          {
            config,
            self',
            inputs',
            pkgs,
            system,
            ...
          }:
          {
            # Apply overlays
            _module.args.pkgs = import nixpkgs {
              inherit system;
              overlays = [ rust-overlay.overlays.default ];
              config.allowUnfree = true;
            };

            # Expose nix2container for container building
            _module.args.nix2containerPkgs = nix2container.packages.${system};

            # Default formatter
            formatter = pkgs.alejandra;

            # Development shell for working on this repository
            devshells.default = {
              name = "nix-shell-templates";
              motd = ''
                {202}Welcome to nix-shell-templates development{reset}
                $(type -p menu &>/dev/null && menu)
              '';
              commands = [
                {
                  name = "fmt";
                  help = "Format Nix files";
                  command = "alejandra .";
                }
                {
                  name = "check";
                  help = "Run flake check";
                  command = "nix flake check";
                }
              ];
              packages = with pkgs; [
                alejandra
                nil
              ];
            };
          };
      }
    );
}
