# =============================================================================
# PowerShell Profile Translated from .zshrc and .zprofile
#
# Location: $PROFILE
# To edit: code $PROFILE
# To apply changes: . $PROFILE
#
# Required Modules (run once in an admin PowerShell session):
# Install-Module -Name PSReadLine -AllowPrerelease -Force
# Install-Module -Name posh-git -Scope CurrentUser
# Install-Module -Name PSFzf -Scope CurrentUser
# Install-Module -Name ZLocation -Scope CurrentUser # zoxide alternative
# Install-Module -Name Terminal-Icons -Scope CurrentUser # For eza-like icons
#
# Recommended Tools (install via winget, scoop, or choco):
# winget install eza
# winget install bat
# winget install fd
# winget install fzf
# winget install neovim
# winget install pyenv-win
# =============================================================================


# -----------------------------------------------------------------------------
# Environment Variables (from .zprofile)
# -----------------------------------------------------------------------------
# --- Generic Exports (Cross-Platform) ---
$env:EDITOR = "nvim" # Changed from "zed" to "nvim" to match aliases
$env:GIT_CONFIG_GLOBAL = "$HOME\.config\git\config"
$env:TEXINPUTS = "$HOME\.config\tex\latex\\;"
$env:NVM_DIR = "$HOME\.nvm"

# --- PATH Configuration ---
# PowerShell's $env:Path is a single semicolon-delimited string.
# We prepend paths to ensure they have priority.
$userPath = @(
    "$HOME\.pyenv\pyenv-win\bin",
    "$HOME\.pyenv\pyenv-win\shims", # Pyenv requires shims path as well
    "$HOME\.config\scripts",
    "$HOME\.cargo\bin",
    "$HOME\.composer\vendor\bin",
    "$HOME\.dotnet\tools",
    "$HOME\.local\bin"
)

# OS-Specific Paths
if ($IsWindows) {
    # Add Windows-specific paths here if needed
} elseif ($IsMacOS) {
    $userPath += "/Applications/Docker.app/Contents/Resources/bin"
    $env:DOTNET_ROOT = "/usr/local/share/dotnet"
    $userPath += "$($env:DOTNET_ROOT)\sdk"
} elseif ($IsLinux) {
    $env:DOTNET_ROOT = "/usr/share/dotnet"
    $userPath += $env:DOTNET_ROOT
    # Add path for mssql-tools if it exists
    if (Test-Path "/opt/mssql-tools18/bin") {
        $userPath += "/opt/mssql-tools18/bin"
    }
}

# Prepend all paths to the main PATH variable
$env:PATH = ($userPath | ForEach-Object { "$_;" }) -join '' + $env:PATH


# --- FZF Configuration ---
# Note: These assume 'fd' and 'bat' are installed and in your PATH.
$env:FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git "
$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND = "fd --type=d --hidden --strip-cwd-prefix --exclude .git"
$env:FZF_CTRL_T_OPTS = "--preview 'bat --color=always -n --line-range :500 {}'"
$env:FZF_ALT_C_OPTS = "--preview 'eza --icons=always --tree --color=always {} | head -200'"
$env:FZF_DEFAULT_OPTS = '--color=fg:15,bg:0,hl:15,fg+:15,bg+:0 --color=hl+:15:bold:underline,info:15,prompt:15,pointer:15:bold --color=marker:15,spinner:15,header:15 --border=rounded --height=40% --reverse --cycle --bind "tab:down,shift-tab:up"'
$env:FZF_TMUX_OPTS = " -p90%,70% "


# -----------------------------------------------------------------------------
# Shell Behavior & Plugins (from .zshrc)
# -----------------------------------------------------------------------------

# --- PSReadLine: Syntax Highlighting, Autosuggestions, and more ---
# This replaces zsh-syntax-highlighting, zsh-autosuggestions, and zsh-autopair
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    # Set prediction source to history (like zsh-autosuggestions)
    Set-PSReadLineOption -PredictionSource History
    # Enable predictive suggestions to appear as you type
    Set-PSReadLineOption -PredictionViewStyle InlineView
    # Enable syntax highlighting
    Set-PSReadLineOption -Colors @{
        Command            = 'White'
        Parameter          = 'Cyan'
        String             = 'Green'
        Variable           = 'Magenta'
        Number             = 'Yellow'
        Type               = 'Yellow'
        Operator           = 'Red'
        Comment            = 'DarkGray'
        Default            = 'Gray'
    }
    # Keybindings for completion and navigation
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# --- Posh-Git: Git info in prompt ---
# Replaces vcs_info
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# --- Terminal-Icons: ls icons ---
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# --- ZLocation: zoxide equivalent ---
if (Get-Module -ListAvailable -Name ZLocation) {
    Import-Module ZLocation
    # This provides the 'z' command
}


# -----------------------------------------------------------------------------
# Custom Prompt (from .zshrc)
# -----------------------------------------------------------------------------
# This function rebuilds the prompt every time it's displayed.
# It shows: (conda_env) path [git_branch] >
function prompt {
    # 1. Conda Environment
    $condaEnv = ""
    if ($env:CONDA_DEFAULT_ENV) {
        $condaEnv = "($($env:CONDA_DEFAULT_ENV)) "
    }

    # 2. Current Path (shortened)
    $shortPath = $pwd.ProviderPath.Replace($HOME, '~')

    # 3. Posh-Git status (handled automatically by posh-git's prompt override)

    # 4. Combine and write output
    # The 'Write-Host' with -NoNewline is key. Posh-git adds the git part.
    Write-Host "$condaEnv$shortPath " -NoNewline -ForegroundColor Green

    # This is a placeholder for the git string that posh-git will write.
    # If posh-git is active, it will overwrite this part of the line.
    $gitPrompt = if (Get-Command Write-VcsStatus -ErrorAction SilentlyContinue) { Write-VcsStatus } else { "" }

    # Final prompt character
    return "$gitPrompt`n> "
}


# -----------------------------------------------------------------------------
# Initializations (from .zshrc)
# -----------------------------------------------------------------------------

# --- Pyenv Initialization ---
if (Get-Command pyenv -ErrorAction SilentlyContinue) {
    # The pyenv-win setup is different and often handled by PATH.
    # If you need hooks, you might run an init script, but it's less common.
    # For example: Invoke-Expression (& 'pyenv' 'init' '-')
}

# --- Conda Initialization ---
# This must be run LAST to ensure conda commands are available.
$condaPath = if ($IsWindows) { "$env:USERPROFILE\anaconda3\Scripts\conda.exe" } else { "$HOME/anaconda3/bin/conda" }
if (Test-Path $condaPath) {
    try {
        & $condaPath "shell.powershell" "hook" | Out-String | Invoke-Expression
    } catch {
        Write-Warning "Conda hook failed to run."
    }
}


# -----------------------------------------------------------------------------
# Aliases (from .zshrc)
# -----------------------------------------------------------------------------
# PowerShell uses Set-Alias for simple aliases. For complex commands with
# arguments or pipes, functions are the recommended approach.

# --- Global Aliases ---
Set-Alias -Name la -Value Get-ChildItem -Force # ls -la equivalent
Set-Alias -Name cls -Value Clear-Host -Force
Set-Alias -Name v -Value nvim -Force
Set-Alias -Name vi -Value nvim -Force
Set-Alias -Name t -Value "tmux attach" -Force
Set-Alias -Name y -Value yazi -Force
Set-Alias -Name gs -Value "git status --short" -Force
Set-Alias -Name what -Value tldr -Force

# --- Functions for Complex Aliases ---
function l {
    # eza --all --icons
    eza --all --icons @args
}

function tree {
    # tree -I "node_modules|bower_components"
    tree -I "node_modules|bower_components" @args
}

function fman {
    # compgen -c | fzf | xargs man
    Get-Command | Select-Object -ExpandProperty Name | fzf | ForEach-Object { man $_ }
}

# --- Script Aliases ---
# Assumes these executables are in your $PATH (e.g., in ~/.config/scripts)
Set-Alias -Name tt -Value "executable_tmux-new" -Force
Set-Alias -Name ccp -Value "executable_create-project" -Force
Set-Alias -Name dp -Value "executable_delete-project" -Force
Set-Alias -Name m -Value "executable_man" -Force
Set-Alias -Name bb -Value "executable_branch-change" -Force


# --- OS Specific Aliases ---
if ($IsWindows) {
    # Add Windows specific aliases here
} elseif ($IsLinux) {
    # Add Linux specific aliases here
    Set-Alias -Name zed -Value zeditor
} elseif ($IsMacOS) {
    # Add macOS specific aliases here
}

# --- Final Welcome Message ---
Write-Host "PowerShell profile loaded." -ForegroundColor Cyan
