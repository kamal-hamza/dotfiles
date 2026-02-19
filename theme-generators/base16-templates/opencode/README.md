# OpenCode Base16 Theme Template

## Overview

This directory contains the Base16 theme template for OpenCode, which generates
theme files compatible with the OpenCode color scheme specification.

## Files

- `templates/default.mustache` - Mustache template for generating OpenCode themes
- `templates/config.yaml` - Configuration for theme output

## Theme Structure

The generated themes follow the OpenCode JSON schema with:

- **defs**: Color definitions mapping Base16 colors to hex values
- **theme**: Theme properties that reference the defined colors

## Color Mapping

Base16 colors are mapped to OpenCode theme properties as follows:

| Base16  | OpenCode Property      | Purpose                |
|---------|------------------------|------------------------|
| base00  | background             | Main background        |
| base01  | backgroundPanel        | Panel background       |
| base02  | backgroundElement      | Element background     |
| base03  | textMuted              | Muted/dim text         |
| base04  | (unused)               | Light foreground       |
| base05  | text                   | Primary text           |
| base06  | (unused)               | Lighter foreground     |
| base07  | (unused)               | Lightest background    |
| base08  | error, diffRemoved     | Red (errors, deleted)  |
| base09  | markdownListEnumeration| Orange (constants)     |
| base0A  | warning, syntaxType    | Yellow (warnings)      |
| base0B  | success, diffAdded     | Green (success, added) |
| base0C  | accent, markdownLink   | Cyan (accents, links)  |
| base0D  | primary, syntaxFunction| Blue (primary, funcs)  |
| base0E  | secondary, syntaxKeyword| Magenta (keywords)    |
| base0F  | syntaxPunctuation      | Brown (punctuation)    |

## Usage

Themes are automatically generated when you run:

```bash
chezmoi apply
```

Or manually with:

```bash
flavours build path/to/scheme.yaml templates/default.mustache > output.json
```

## Generated Themes

Generated theme files are placed in:
`~/.config/opencode/themes/base16-{scheme-name}.json`

## Schema Compliance

The generated themes comply with the OpenCode JSON schema, supporting:

- Color definitions (hex, ANSI codes, or references)
- Full theme property set including:
  - Core colors (primary, secondary, accent, etc.)
  - Background variants
  - Border colors
  - Diff highlighting
  - Markdown styling
  - Syntax highlighting
