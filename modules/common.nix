# Common module - shared configuration and base options for all templates
#
# This module provides:
# - Shared option definitions under `templates` namespace
# - Common devshell configuration patterns
# - Base packages that are useful across all environments
{
  lib,
  config,
  ...
}:
let
  cfg = config.templates;
in
{
  options.templates = {
    # Project metadata (optional, used in MOTD and container labels)
    projectName = lib.mkOption {
      type = lib.types.str;
      default = "dev-environment";
      description = "Name of the project (used in shell MOTD and container labels)";
    };

    projectDescription = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Description of the project";
    };

    # Common packages to include in all enabled devshells
    commonPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Common packages to include in all enabled development shells";
    };

    # Enable debug mode for additional verbosity
    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable debug mode for verbose output";
    };
  };

  config = {
    # This module doesn't define any outputs directly
    # It only provides shared options for other modules to use
  };
}
