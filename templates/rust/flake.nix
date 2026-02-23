# Rust Development Template
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates#rust
#
# Provides a complete Rust development environment with:
# - Rust toolchain (configurable channel/version)
# - rust-analyzer, clippy, rustfmt
# - Common cargo tools (cargo-watch, cargo-edit, etc.)
{
  description = "Rust development environment";

  inputs = {
    nix-shell-templates.url = "github:sibeov/nix-shell-templates";
    nixpkgs.follows = "nix-shell-templates/nixpkgs";
    flake-parts.follows = "nix-shell-templates/flake-parts";
    devshell.follows = "nix-shell-templates/devshell";
    rust-overlay.follows = "nix-shell-templates/rust-overlay";
  };

  outputs =
    inputs@{
      self,
      nix-shell-templates,
      nixpkgs,
      flake-parts,
      devshell,
      rust-overlay,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devshell.flakeModule
        nix-shell-templates.flakeModules.common
        nix-shell-templates.flakeModules.rust
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Project configuration
      templates.projectName = "rust-project";

      # Rust module configuration
      templates.rust = {
        enable = true;

        # Toolchain channel: "stable", "beta", or "nightly"
        channel = "stable";

        # Specific version (uncomment to pin)
        # version = "1.75.0";

        # Rust edition for new projects
        edition = "2021";

        # Components to install
        components = [
          "rustfmt"
          "clippy"
          "rust-analyzer"
        ];

        # Cross-compilation targets (uncomment as needed)
        targets = [
          # "wasm32-unknown-unknown"
          # "aarch64-unknown-linux-gnu"
        ];

        # Include cargo helper tools
        includeCargoTools = true;

        # Extra packages
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
          # Apply rust overlay for toolchain selection
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };

          # Default formatter (official Nix formatter per RFC 166)
          formatter = pkgs.nixfmt;

          # Make the Rust shell the default
          devShells.default = config.devShells.rust;
        };
    };
}
