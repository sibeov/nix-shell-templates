# Rust Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#rust
#
# This template reads the Rust toolchain from rust-toolchain.toml,
# making it compatible with both Nix and rustup users.
{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      rust-overlay,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        let
          # Read toolchain from rust-toolchain.toml (works with rustup too)
          rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

          # Common cargo tools
          cargoTools = with pkgs; [
            cargo-watch
            cargo-edit
            cargo-audit
            cargo-outdated
            cargo-nextest
          ];
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };

          # Export toolchain as a package
          packages.rust-toolchain = rustToolchain;

          # Default formatter
          formatter = pkgs.nixfmt;

          # Development shell
          devShells.default = pkgs.mkShell {
            name = "rust-dev";

            buildInputs = [
              rustToolchain
            ]
            ++ cargoTools;

            env = {
              RUST_BACKTRACE = "1";
              CARGO_TERM_COLOR = "always";
            };

            shellHook = ''
              echo "Rust Development Environment"
              echo "Toolchain: $(rustc --version)"
              echo ""
              echo "Available commands:"
              echo "  cargo build    - Build the project"
              echo "  cargo test     - Run tests"
              echo "  cargo clippy   - Run linter"
              echo "  cargo fmt      - Format code"
              echo "  cargo watch    - Watch for changes"
              echo ""
            '';
          };
        };
    };
}
