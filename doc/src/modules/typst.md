# Typst Module

Provides a Typst document development environment with LSP support and fonts.

## Features

- **Typst compiler**: Modern typesetting system
- **LSP support**: typst-lsp and tinymist for editor integration
- **PDF preview**: zathura with auto-reload
- **Watch mode**: Automatic recompilation on changes
- **Fonts**: Common font families included

## Quick Start

```bash
nix flake init -t github:sibeov/nix-shell-templates#typst
nix develop
```

## Options

### `templates.typst.enable`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `false` |

Enable the Typst development environment.

### `templates.typst.includeLsp`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include Typst LSP for editor integration (typst-lsp and tinymist).

### `templates.typst.includePdfViewer`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include a PDF viewer (zathura).

### `templates.typst.includeWatchTools`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include tools for watch mode (watchexec).

### `templates.typst.includeFonts`

| Property | Value |
|----------|-------|
| Type | `boolean` |
| Default | `true` |

Include common font packages.

### `templates.typst.extraFonts`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Additional font packages to include.

### `templates.typst.defaultFormat`

| Property | Value |
|----------|-------|
| Type | `enum: "pdf"`, `"png"`, `"svg"` |
| Default | `"pdf"` |

Default output format for compilation.

### `templates.typst.extraPackages`

| Property | Value |
|----------|-------|
| Type | `list of package` |
| Default | `[]` |

Additional Nix packages to include.

## Shell Commands

| Command | Description |
|---------|-------------|
| `typst-info` | Show Typst environment information |
| `compile <file.typ> [output]` | Compile a Typst document |
| `watch <file.typ>` | Watch and recompile on changes |
| `preview <file.typ>` | Compile and open PDF for preview |
| `watch-preview <file.typ>` | Watch, recompile, and auto-refresh PDF |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TYPST_FONT_PATHS` | Paths to font directories |
| `FONTCONFIG_PATH` | Fontconfig configuration path |

## Example Configurations

### Default setup

```nix
templates.typst = {
  enable = true;
};
```

### Academic writing with extra fonts

```nix
templates.typst = {
  enable = true;
  extraFonts = with pkgs; [
    corefonts
    vistafonts
    eb-garamond
    libertinus
  ];
};
```

### Minimal (no preview tools)

```nix
templates.typst = {
  enable = true;
  includePdfViewer = false;
  includeWatchTools = false;
};
```

### PNG output default

```nix
templates.typst = {
  enable = true;
  defaultFormat = "png";
};
```

## Included Fonts

When `includeFonts = true`:

| Font Package | Fonts Included |
|--------------|----------------|
| liberation_ttf | Liberation Sans, Serif, Mono |
| noto-fonts | Noto Sans, Serif |
| noto-fonts-emoji | Noto Color Emoji |
| fira-code | Fira Code (programming) |
| fira-mono | Fira Mono |
| source-serif | Source Serif Pro |
| source-sans | Source Sans Pro |
| source-code-pro | Source Code Pro |

## Workflow

1. Create document: `main.typ`
2. Start preview: `watch-preview main.typ`
3. Edit in your editor (VSCode, Neovim with LSP)
4. PDF auto-refreshes on save

## Editor Setup

### VS Code

Install the [Typst LSP extension](https://marketplace.visualstudio.com/items?itemName=nvarner.typst-lsp). The LSP binary is automatically available in the shell.

### Neovim

Configure with nvim-lspconfig:

```lua
require('lspconfig').typst_lsp.setup{}
-- or
require('lspconfig').tinymist.setup{}
```

## Exported Packages

| Package | Description |
|---------|-------------|
| `packages.typst` | The Typst compiler |
