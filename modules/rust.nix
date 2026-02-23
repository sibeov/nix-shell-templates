# Rust development module
#
# Provides a modern Rust development environment using rust-overlay.
# Supports stable, beta, and nightly toolchains with customizable components.
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

    # Toolchain channel
    channel = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "beta"
        "nightly"
      ];
      default = "stable";
      description = "Rust toolchain channel (stable, beta, or nightly)";
    };

    # Specific version (optional, overrides channel)
    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "1.75.0";
      description = "Specific Rust version. If null, uses latest from channel.";
    };

    # Rust edition for new projects
    edition = lib.mkOption {
      type = lib.types.str;
      default = "2021";
      description = "Rust edition for new projects";
    };

    # Additional components
    components = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "rustfmt"
        "clippy"
        "rust-analyzer"
      ];
      description = "Rust components to include";
    };

    # Target platforms for cross-compilation
    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "wasm32-unknown-unknown"
        "aarch64-unknown-linux-gnu"
      ];
      description = "Additional compilation targets";
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
        # Build rust toolchain using rust-overlay
        # Note: This expects the rust-overlay to be applied in the parent flake
        rustToolchain =
          if cfg.version != null then
            pkgs.rust-bin.${cfg.channel}.${cfg.version}.default.override {
              extensions = cfg.components;
              targets = cfg.targets;
            }
          else
            pkgs.rust-bin.${cfg.channel}.latest.default.override {
              extensions = cfg.components;
              targets = cfg.targets;
            };

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
            {bold}Channel: ${cfg.channel}${lib.optionalString (cfg.version != null) " (${cfg.version})"}{reset}
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
