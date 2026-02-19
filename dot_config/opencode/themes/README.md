# OpenCode Base16 Themes

This directory contains automatically generated Base16 themes for OpenCode.

## Available Themes

**Total: 20 themes (10 dark, 10 light)**

### Dark Themes

1. **ancient-canopy-dark** - Forest greens with muted earth tones
2. **cobalt-lab-dark** - Modern tech lab with vibrant blues
3. **hearth-dark** - Warm fireplace-inspired browns and oranges
4. **night-city-high-dark** - Cyberpunk neon colors
5. **obsidian-sand-dark** - Desert blacks with sandy accents
6. **pacific-umbra-dark** - Deep ocean blues and teals
7. **shinjuku-veridian-dark** - Urban green with tech blues
8. **soft-focus-dark** - Soft, easy-on-the-eyes pastels
9. **vercel-dark** - Clean modern design system
10. **white-sands-dark** - Beach whites with ocean blues

### Light Themes

1. **ancient-canopy-light** - Light forest greens
2. **cobalt-lab-light** - Bright tech lab blues
3. **hearth-light** - Warm light browns
4. **night-city-light** - Bright cyberpunk
5. **obsidian-sand-light** - Light desert tones
6. **pacific-umbra-light** - Light ocean blues
7. **shinjuku-veridian-light** - Light urban greens
8. **soft-focus-light** - Soft light pastels
9. **vercel-light** - Clean light design
10. **white-sands-light** - Bright beach tones

## Usage

These themes are automatically generated from Base16 schemes. To use a theme in OpenCode:

1. Reference it in your OpenCode configuration
2. The themes follow the OpenCode JSON schema specification
3. Each theme includes:
   - Color definitions (`defs`)
   - Theme properties (`theme`)
   - Full support for UI, diff, markdown, and syntax highlighting

## Generation

Themes are automatically regenerated when:
- Running `chezmoi apply`
- The active scheme in `.chezmoidata/theme.yaml` changes
- The generation script is modified

To manually regenerate all themes:

```bash
cd ~/.local/share/chezmoi
for scheme in theme-generators/base16-schemes/*.yaml; do
  scheme_name=$(basename "$scheme" .yaml)
  flavours build "$scheme" \
    theme-generators/base16-templates/opencode/templates/default.mustache \
    > dot_config/opencode/themes/base16-${scheme_name}.json
done
```

## Schema Compliance

All themes comply with the OpenCode JSON schema:
- ✅ JSON Schema draft-07
- ✅ Color definitions in `defs`
- ✅ Theme properties with references
- ✅ Required properties: primary, secondary, accent, text, textMuted, background
- ✅ Optional properties: All diff, markdown, and syntax highlighting properties

## File Format

Each theme file follows this structure:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "defs": {
    "base00": "#......",
    ...
  },
  "theme": {
    "primary": "base0D",
    ...
  }
}
```

## Validation

All 20 themes have been validated for:
- ✅ Valid JSON syntax
- ✅ Required schema properties
- ✅ Color reference integrity
- ✅ Base16 color mapping
