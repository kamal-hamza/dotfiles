# Development Tools Configuration

This directory is for **machine-specific** development tool environment variables.

**Important**: Files in this directory are **NOT tracked by chezmoi**. Each machine can have its own tools configured without affecting other machines.

## How It Works

1. Create `.zsh` files in this directory for each development tool
2. They will be automatically sourced in alphabetical order during shell startup
3. Each machine can have different tools configured

## File Naming Convention

Use descriptive names with the tool name:

- `bun.zsh` - Bun runtime configuration
- `go.zsh` - Go language configuration
- `dotnet.zsh` - .NET SDK configuration
- `node.zsh` - Node.js configuration
- `python.zsh` - Python configuration
- `rust.zsh` - Rust configuration
- etc.

## Example Files

See the `.example` files in this directory for templates.

## Usage Examples

### Bun

Create `bun.zsh`:

```bash
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

### Go

Create `go.zsh`:

```bash
# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"
```

### .NET

Create `dotnet.zsh`:

```bash
# .NET
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
```

### Node.js (nvm)

Create `node.zsh`:

```bash
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
```

### Python (pyenv)

Create `python.zsh`:

```bash
# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
```

### Rust (already configured)

Rust is already configured in `.zprofile` with `$HOME/.cargo/bin` in PATH.

### Java

Create `java.zsh`:

```bash
# Java
export JAVA_HOME="$(/usr/libexec/java_home)"  # macOS
# export JAVA_HOME="/usr/lib/jvm/default"     # Arch Linux
export PATH="$JAVA_HOME/bin:$PATH"
```

### Ruby (rbenv)

Create `ruby.zsh`:

```bash
# Rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi
```

### PHP (Composer)

Create `php.zsh`:

```bash
# PHP Composer
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
```

### Deno

Create `deno.zsh`:

```bash
# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
```

### Zig

Create `zig.zsh`:

```bash
# Zig
export PATH="$HOME/.zig:$PATH"
```

## Tips

1. **Keep it organized**: One file per tool
2. **Check before sourcing**: Use `command -v` to check if a tool exists
3. **Order matters**: Files are sourced alphabetically, prefix with numbers if order is important (e.g., `01-nvm.zsh`, `02-node.zsh`)
4. **Document**: Add comments explaining what each env var does

## Benefits

✅ Machine-specific configurations  
✅ Not tracked by Git/chezmoi  
✅ Easy to add/remove tools  
✅ Clean separation from main config  
✅ Modular and maintainable  
✅ No conflicts between machines
