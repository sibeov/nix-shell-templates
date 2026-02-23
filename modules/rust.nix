# Rust development module
#
# Provides a Rust development environment using rust-overlay.
# Reads toolchain configuration from rust-toolchain.toml for compatibility
# with both Nix and rustup users.
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates.rust;
in
{
  options.templates.rust = {
    enable = lib.mkEnableOption "Rust development environment";

    # Path to rust-toolchain.toml file (required)
    toolchainFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to rust-toolchain.toml file.
        This file is read by both Nix (via rust-overlay) and rustup,
        ensuring consistent toolchain across environments.
      '';
      example = "./rust-toolchain.toml";
    };

    # Rust edition for new projects
    edition = lib.mkOption {
      type = lib.types.str;
      default = "2024";
      description = "Rust edition for new projects created with new-project command";
    };

    # Additional packages
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to include in the Rust development shell";
    };

    # Include common cargo tools
    includeCargoTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include common cargo tools (cargo-watch, cargo-edit, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    perSystem =
      { pkgs, ... }:
      let
        # Read toolchain from rust-toolchain.toml
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile cfg.toolchainFile;

        # Common cargo tools
        cargoTools = lib.optionals cfg.includeCargoTools (
          with pkgs;
          [
            cargo-watch
            cargo-edit
            cargo-audit
            cargo-outdated
            cargo-nextest
          ]
        );

        # All Rust-related packages
        rustPackages = [
          rustToolchain
        ]
        ++ cargoTools
        ++ cfg.extraPackages
        ++ config.templates.commonPackages;
      in
      {
        # Export the rust toolchain as a package
        packages.rust-toolchain = rustToolchain;

        # Development shell using devshell
        devshells.rust = {
          name = "rust-dev";
          motd = ''
            {202}Rust Development Environment{reset}
            {bold}Toolchain from: rust-toolchain.toml{reset}
            Edition: ${cfg.edition}

            $(type -p menu &>/dev/null && menu)
          '';

          packages = rustPackages;

          env = [
            {
              name = "RUST_BACKTRACE";
              value = "1";
            }
            {
              name = "CARGO_TERM_COLOR";
              value = "always";
            }
          ];

          commands = [
            {
              name = "rust-info";
              help = "Show Rust toolchain information";
              command = ''
                echo "Rust    : $(rustc --version)"
                echo "Cargo   : $(cargo --version)"
                echo "Rustfmt : $(rustfmt --version 2>/dev/null || echo 'not installed')"
                echo "Clippy  : $(cargo clippy --version 2>/dev/null || echo 'not installed')"
              '';
            }
            {
              name = "new-project";
              help = "Create a new Rust project with edition ${cfg.edition}";
              command = ''
                if [ -z "$1" ]; then
                  echo "Usage: new-project <name>"
                  exit 1
                fi
                cargo new --edition ${cfg.edition} "$@"
              '';
            }
            {
              name = "check-all";
              help = "Run cargo check, clippy, and fmt";
              command = ''
                echo "Running cargo check..."
                cargo check --all-targets
                echo "Running clippy..."
                cargo clippy --all-targets -- -D warnings
                echo "Checking formatting..."
                cargo fmt -- --check
              '';
            }
            {
              name = "watch";
              help = "Watch for changes and run cargo check";
              command = "cargo watch -x check";
              category = "development";
            }
          ];
        };
      };
  };
}
