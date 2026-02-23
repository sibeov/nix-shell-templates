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
    nix2container = {
      url = "github:nlewo/nix2container";
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
          inputs',
          config,
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

          # OCI image for containerized development
          packages.ociImage =
            let
              n2c = inputs'.nix2container.packages.nix2container;
            in
            n2c.buildImage {
              name = "rust-dev";
              tag = "latest";
              copyToRoot = pkgs.buildEnv {
                name = "root";
                paths = [
                  rustToolchain
                  pkgs.bashInteractive
                  pkgs.coreutils
                  pkgs.git
                ]
                ++ cargoTools;
                pathsToLink = [
                  "/bin"
                  "/lib"
                  "/share"
                ];
              };
              config = {
                Entrypoint = [ "/bin/bash" ];
                Env = [
                  "RUST_BACKTRACE=1"
                  "CARGO_TERM_COLOR=always"
                  "USER=rust"
                ];
                WorkingDir = "/workspace";
                Labels = {
                  "org.opencontainers.image.description" = "Rust development environment";
                  "org.opencontainers.image.source" = "https://github.com/sibeov/nix-shell-templates";
                };
              };
            };

          # Default formatter
          formatter = pkgs.nixfmt;

          # Apps for container management
          apps.pushImage = {
            type = "app";
            program = "${config.packages.ociImage}/bin/copy-to-registry";
          };

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
              echo "Container commands:"
              echo "  nix build .#ociImage           - Build OCI image"
              echo "  nix run .#pushImage            - Push to registry"
              echo ""
            '';
          };
        };
    };
}
