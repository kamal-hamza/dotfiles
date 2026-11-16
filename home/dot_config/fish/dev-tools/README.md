# Development tool configuration (fish)

Machine-specific environment for development tools. Every `*.fish` file here
is sourced (alphabetically) by `conf.d/90-dev-tools.fish`, and is **not
tracked by chezmoi** (`.chezmoiignore` ignores `.config/fish/dev-tools/*.fish`).
The `*.fish.example` files are tracked templates.

```sh
dev-tool list          # examples + which are active
dev-tool add go        # copy go.fish.example -> go.fish, then edit it
dev-tool edit go
dev-tool show go
dev-tool remove go
```

Use `set -gx` for variables and `fish_add_path -g` for PATH entries (`-g`
keeps them out of fish's universal variables). Prefix files with numbers
(`01-…`) if load order matters.

Env that every machine needs belongs in `.chezmoidata/shell.yaml` instead.
