# Common Module

The common module provides shared configuration options used by all other modules.

## Purpose

This module defines the `templates` option namespace and shared settings that apply across all development environments. It doesn't create a devshell itself but provides options that other modules reference.

## Options

### `templates.projectName`

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"dev-environment"` |

Name of the project, used in shell MOTD and container labels.

```nix
templates.projectName = "my-awesome-project";
```

### `templates.projectDescription`

| Property | Value |
|----------|-------|
| Type | `null` or `string` |
| Default | `null` |

Optional description of the project.

```nix
templates.projectDescription = "A really cool project";
```

### `templates.commonPackages`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Packages to include in all enabled development shells. Useful for tools you want available everywhere.

```nix
templates.commonPackages = with pkgs; [
  git
  curl
  jq
  ripgrep
];
```

### `templates.debug`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable debug mode for verbose output during shell initialization.

```nix
templates.debug = true;
```

## Example Usage

```nix
{
  # Common settings applied to all modules
  templates.projectName = "my-project";
  templates.projectDescription = "My development project";
  
  # Packages available in every shell
  templates.commonPackages = with pkgs; [
    git
    gh
    just
  ];
  
  # Enable specific modules
  templates.rust.enable = true;
  templates.python.enable = true;
}
```

When both Rust and Python modules are enabled, both `devShells.rust` and `devShells.python` will include git, gh, and just.
