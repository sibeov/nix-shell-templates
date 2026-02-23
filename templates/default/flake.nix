# Default template - All modules available, enable what you need
#
# Usage: nix flake init -t github:sibeov/nix-shell-templates
#
# This template provides all available development environments.
# Uncomment/modify the modules you want to enable below.
{
  description = "Development environment - customize by enabling modules";

  inputs = {
    # Main flake with all modules
    nix-shell-templates.url = "github:sibeov/nix-shell-templates";

    # Follow nixpkgs from the templates flake for consistency
    nixpkgs.follows = "nix-shell-templates/nixpkgs";
    flake-parts.follows = "nix-shell-templates/flake-parts";
    devshell.follows = "nix-shell-templates/devshell";

    # Rust overlay (if using Rust)
    rust-overlay.follows = "nix-shell-templates/rust-overlay";

    # Container support
    nix2container.follows = "nix-shell-templates/nix2container";
  };

  outputs =
    inputs@{
      self,
      nix-shell-templates,
      nixpkgs,
      flake-parts,
      devshell,
      rust-overlay,
      nix2container,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Import devshell for development shells
        devshell.flakeModule

        # Import all template modules
        nix-shell-templates.flakeModules.common
        nix-shell-templates.flakeModules.fpga
        nix-shell-templates.flakeModules.rust
        nix-shell-templates.flakeModules.python
        nix-shell-templates.flakeModules.typst
        nix-shell-templates.flakeModules.containers
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # ========================================
      # TEMPLATE CONFIGURATION
      # ========================================
      # Uncomment and configure the modules you need:

      # Common settings (applied to all enabled modules)
      templates.projectName = "my-project";
      # templates.projectDescription = "My awesome project";
      # templates.commonPackages = [ ]; # Packages available in all shells

      # ----------------------------------------
      # FPGA Development
      # ----------------------------------------
      # Uncomment to enable FPGA development with oss-cad-suite
      # Requires an oss-cad-suite.nix file in the project root
      # templates.fpga = {
      #   enable = true;
      #   ossCadSuiteFile = ./oss-cad-suite.nix;  # Required: path to package file
      #   includeVerible = true;                  # SystemVerilog linter/formatter
      #   extraPackages = [ ];
      # };

      # ----------------------------------------
      # Rust Development
      # ----------------------------------------
      # Uncomment to enable Rust development
      # Requires a rust-toolchain.toml file in the project root
      # templates.rust = {
      #   enable = true;
      #   toolchainFile = ./rust-toolchain.toml;  # Required: path to toolchain file
      #   edition = "2024";                       # Rust edition for new projects
      #   includeCargoTools = true;               # cargo-watch, cargo-edit, etc.
      #   extraPackages = [ ];
      # };

      # ----------------------------------------
      # Python Development
      # ----------------------------------------
      # Uncomment to enable Python development
      # Requires a .python-version file in the project root (e.g., "3.13")
      # templates.python = {
      #   enable = true;
      #   pythonVersionFile = ./.python-version;  # Required: path to version file
      #   venvDir = ".venv";                      # Virtual environment directory
      #   includeDevTools = true;                 # ruff, mypy, pyright
      #   includeJupyter = false;                 # Jupyter notebook
      #   extraPackages = [ ];
      # };

      # ----------------------------------------
      # Typst Development
      # ----------------------------------------
      # Uncomment to enable Typst document development
      # templates.typst = {
      #   enable = true;
      #   includeLsp = true;                # LSP for editor integration
      #   includePdfViewer = true;          # PDF viewer (zathura)
      #   includeWatchTools = true;         # Watch mode tools
      #   includeFonts = true;              # Common fonts
      #   defaultFormat = "pdf";            # pdf, png, or svg
      #   extraFonts = [ ];
      #   extraPackages = [ ];
      # };

      # ----------------------------------------
      # Container Support
      # ----------------------------------------
      # Uncomment to enable OCI container building
      # templates.containers = {
      #   enable = true;
      #   # Containers are built for enabled modules automatically
      # };

      # ========================================
      # Per-system configuration
      # ========================================
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          # Apply rust overlay
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
            config.allowUnfree = true;
          };

          # Container building support
          _module.args.nix2containerPkgs = nix2container.packages.${system};

          # Default formatter (official Nix formatter per RFC 166)
          formatter = pkgs.nixfmt;

          # You can add additional packages, devShells, etc. here
          # packages.mypackage = ...;
          # devShells.custom = ...;
        };
    };
}
