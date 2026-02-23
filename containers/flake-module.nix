# Container support module using nix2container
#
# This module provides OCI-compliant container images for each enabled template.
# Containers mirror the development environment, making it easy to use the same
# tools in CI/CD pipelines or non-Nix environments.
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates.containers;
in
{
  options.templates.containers = {
    enable = lib.mkEnableOption "OCI container image building";

    # Registry configuration
    registry = lib.mkOption {
      type = lib.types.str;
      default = "localhost:5000";
      description = "Default container registry for push operations";
    };

    # Image name prefix
    imagePrefix = lib.mkOption {
      type = lib.types.str;
      default = "nix-shell-templates";
      description = "Prefix for container image names";
    };

    # Tag for images
    tag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "Tag for container images";
    };
  };

  config = lib.mkIf cfg.enable {
    perSystem =
      {
        pkgs,
        system,
        nix2containerPkgs ? null,
        ...
      }:
      let
        # Only build containers if nix2container is available
        hasNix2Container = nix2containerPkgs != null;
        nix2container = if hasNix2Container then nix2containerPkgs.nix2container else null;

        # Helper to build containers
        buildContainer =
          {
            name,
            packages,
            entrypoint ? [ "/bin/sh" ],
            env ? { },
            description ? "Container built with nix2container",
          }:
          if !hasNix2Container then
            null
          else
            nix2container.buildImage {
              name = "${cfg.imagePrefix}/${name}";
              tag = cfg.tag;

              copyToRoot = pkgs.buildEnv {
                name = "root";
                paths = packages ++ [
                  pkgs.bashInteractive
                  pkgs.coreutils
                ];
                pathsToLink = [
                  "/bin"
                  "/lib"
                  "/share"
                ];
              };

              config = {
                Entrypoint = entrypoint;
                Env = lib.mapAttrsToList (k: v: "${k}=${v}") env;
                Labels = {
                  "org.opencontainers.image.description" = description;
                  "org.opencontainers.image.source" = "https://github.com/sibeov/nix-shell-templates";
                };
              };
            };

        # FPGA container
        fpgaContainer =
          if config.templates.fpga.enable && hasNix2Container then
            let
              oss-cad-suite = pkgs.callPackage ../templates/oss-cad-suite.nix {
                inherit system;
                version = config.templates.fpga.version;
                dateVersion = config.templates.fpga.dateVersion;
              };
            in
            buildContainer {
              name = "fpga";
              packages = [
                oss-cad-suite
              ]
              ++ lib.optionals config.templates.fpga.includeGtkwave [ pkgs.gtkwave ]
              ++ lib.optionals config.templates.fpga.includeVerilator [ pkgs.verilator ];
              entrypoint = [ "/bin/bash" ];
              env = {
                OSS_CAD_SUITE_ROOT = "${oss-cad-suite}";
              };
              description = "FPGA development container with oss-cad-suite";
            }
          else
            null;

        # Rust container
        rustContainer =
          if config.templates.rust.enable && hasNix2Container then
            let
              rustToolchain = pkgs.rust-bin.fromRustupToolchainFile config.templates.rust.toolchainFile;
            in
            buildContainer {
              name = "rust";
              packages = [
                rustToolchain
              ]
              ++ lib.optionals config.templates.rust.includeCargoTools [
                pkgs.cargo-watch
                pkgs.cargo-edit
              ];
              entrypoint = [ "/bin/bash" ];
              env = {
                RUST_BACKTRACE = "1";
                CARGO_TERM_COLOR = "always";
              };
              description = "Rust development container";
            }
          else
            null;

        # Python container
        pythonContainer =
          if config.templates.python.enable && hasNix2Container then
            let
              python = pkgs.${config.templates.python.pythonVersion};
            in
            buildContainer {
              name = "python";
              packages = [
                python
              ]
              ++ lib.optionals config.templates.python.useUv [ pkgs.uv ]
              ++ lib.optionals config.templates.python.includeDevTools [
                pkgs.ruff
                pkgs.mypy
              ];
              entrypoint = [ "/bin/bash" ];
              env = {
                PYTHONDONTWRITEBYTECODE = "1";
                PYTHONUNBUFFERED = "1";
              };
              description = "Python development container";
            }
          else
            null;

        # Typst container
        typstContainer =
          if config.templates.typst.enable && hasNix2Container then
            buildContainer {
              name = "typst";
              packages = [
                pkgs.typst
              ]
              ++ lib.optionals config.templates.typst.includeLsp [
                pkgs.typst-lsp
                pkgs.tinymist
              ]
              ++ lib.optionals config.templates.typst.includeFonts [
                pkgs.liberation_ttf
                pkgs.noto-fonts
                pkgs.fira-code
              ];
              entrypoint = [ "/bin/bash" ];
              description = "Typst document development container";
            }
          else
            null;
      in
      {
        # Export container images as packages
        packages =
          lib.optionalAttrs (fpgaContainer != null) {
            "container-fpga" = fpgaContainer;
          }
          // lib.optionalAttrs (rustContainer != null) {
            "container-rust" = rustContainer;
          }
          // lib.optionalAttrs (pythonContainer != null) {
            "container-python" = pythonContainer;
          }
          // lib.optionalAttrs (typstContainer != null) {
            "container-typst" = typstContainer;
          };
      };
  };
}
