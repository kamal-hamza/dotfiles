# Theme Switcher for Soft Focus Dotfiles (Windows PowerShell)
# Switches between light and dark themes across all applications
# Author: Hamza Kamal

param(
    [Parameter(Position=0)]
    [ValidateSet("dark", "light", "toggle", "auto", "status", "help")]
    [string]$Command = "help"
)

# Configuration
$ConfigDir = $env:APPDATA
$ThemeStateFile = "$ConfigDir\.soft-focus-theme"
$DarkStartHour = 18
$DarkEndHour = 8

# Color output functions
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Print-Header {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  🎨 Soft Focus Theme Switcher" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

# Get current theme
function Get-CurrentTheme {
    if (Test-Path $ThemeStateFile) {
        return Get-Content $ThemeStateFile -Raw
    }
    return "dark"
}

# Save theme state
function Save-ThemeState {
    param([string]$Theme)
    Set-Content -Path $ThemeStateFile -Value $Theme -NoNewline
}

# Application-specific theme switchers

function Switch-KittyTheme {
    param([string]$Theme)

    $kittyConf = "$env:APPDATA\kitty\kitty.conf"

    if (-not (Test-Path $kittyConf)) {
        Write-Warning-Custom "Kitty config not found, skipping"
        return
    }

    $content = Get-Content $kittyConf
    $newContent = $content -replace "include themes/soft-focus-.*\.conf", "include themes/soft-focus-$Theme.conf"

    if ($content -ne $newContent) {
        Set-Content -Path $kittyConf -Value $newContent
        Write-Success "Kitty theme updated"
    } else {
        Write-Warning-Custom "Kitty theme include not found in config"
    }
}

function Switch-WezTermTheme {
    param([string]$Theme)

    Write-Info "WezTerm: Please restart to apply theme changes"
}

function Switch-TmuxTheme {
    param([string]$Theme)

    # Tmux on Windows typically runs in WSL
    Write-Info "Tmux: Update theme in WSL environment"
}

function Switch-YaziTheme {
    param([string]$Theme)

    $yaziTheme = "$env:APPDATA\yazi\config\theme.toml"

    if (-not (Test-Path $yaziTheme)) {
        Write-Warning-Custom "Yazi theme config not found, skipping"
        return
    }

    $content = Get-Content $yaziTheme -Raw
    $newContent = $content -replace "themes/soft-focus-.*\.toml", "themes/soft-focus-$Theme.toml"

    if ($content -ne $newContent) {
        Set-Content -Path $yaziTheme -Value $newContent -NoNewline
        Write-Success "Yazi theme updated"
    }
}

function Switch-BtopTheme {
    param([string]$Theme)

    $btopConf = "$env:APPDATA\btop\btop.conf"

    if (-not (Test-Path $btopConf)) {
        Write-Warning-Custom "btop config not found, skipping"
        return
    }

    $content = Get-Content $btopConf
    $newContent = $content -replace 'color_theme = "soft-focus-.*"', "color_theme = `"soft-focus-$Theme`""

    if ($content -ne $newContent) {
        Set-Content -Path $btopConf -Value $newContent
        Write-Success "btop theme updated"
    }
}

function Switch-NvimTheme {
    param([string]$Theme)

    Write-Info "Neovim: Theme will update on next launch (vim.o.background='$Theme')"
}

function Switch-ZedTheme {
    param([string]$Theme)

    $zedSettings = "$env:APPDATA\Zed\settings.json"

    if (-not (Test-Path $zedSettings)) {
        Write-Warning-Custom "Zed settings not found, skipping"
        return
    }

    $content = Get-Content $zedSettings -Raw

    if ($Theme -eq "dark") {
        $newContent = $content -replace '"theme": "Soft Focus Light"', '"theme": "Soft Focus Dark"'
    } else {
        $newContent = $content -replace '"theme": "Soft Focus Dark"', '"theme": "Soft Focus Light"'
    }

    if ($content -ne $newContent) {
        Set-Content -Path $zedSettings -Value $newContent -NoNewline
        Write-Success "Zed theme updated"
    }
}

function Switch-VSCodeTheme {
    param([string]$Theme)

    $vscodeSettings = "$env:APPDATA\Code\User\settings.json"

    if (-not (Test-Path $vscodeSettings)) {
        return
    }

    $content = Get-Content $vscodeSettings -Raw

    if ($Theme -eq "dark") {
        $newContent = $content -replace '"workbench.colorTheme": "Soft Focus Light"', '"workbench.colorTheme": "Soft Focus Dark"'
    } else {
        $newContent = $content -replace '"workbench.colorTheme": "Soft Focus Dark"', '"workbench.colorTheme": "Soft Focus Light"'
    }

    if ($content -ne $newContent) {
        Set-Content -Path $vscodeSettings -Value $newContent -NoNewline
        Write-Success "VS Code theme updated"
    }
}

function Switch-WindowsTerminalTheme {
    param([string]$Theme)

    $wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (-not (Test-Path $wtSettings)) {
        Write-Warning-Custom "Windows Terminal settings not found, skipping"
        return
    }

    $content = Get-Content $wtSettings -Raw

    if ($Theme -eq "dark") {
        $newContent = $content -replace '"colorScheme": "Soft Focus Light"', '"colorScheme": "Soft Focus Dark"'
    } else {
        $newContent = $content -replace '"colorScheme": "Soft Focus Dark"', '"colorScheme": "Soft Focus Light"'
    }

    if ($content -ne $newContent) {
        Set-Content -Path $wtSettings -Value $newContent -NoNewline
        Write-Success "Windows Terminal theme updated"
    }
}

function Switch-WindowsAppearance {
    param([string]$Theme)

    try {
        $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"

        if ($Theme -eq "dark") {
            Set-ItemProperty -Path $registryPath -Name "AppsUseLightTheme" -Value 0 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "SystemUsesLightTheme" -Value 0 -Type DWord
            Write-Success "Windows system appearance set to dark"
        } else {
            Set-ItemProperty -Path $registryPath -Name "AppsUseLightTheme" -Value 1 -Type DWord
            Set-ItemProperty -Path $registryPath -Name "SystemUsesLightTheme" -Value 1 -Type DWord
            Write-Success "Windows system appearance set to light"
        }
    } catch {
        Write-Warning-Custom "Could not update Windows appearance: $_"
    }
}

# Main switching logic
function Switch-Theme {
    param([string]$TargetTheme)

    Write-Host ""
    Write-Info "Switching to $TargetTheme theme..."
    Write-Host ""

    # Update all applications
    Switch-KittyTheme $TargetTheme
    Switch-WezTermTheme $TargetTheme
    Switch-TmuxTheme $TargetTheme
    Switch-YaziTheme $TargetTheme
    Switch-BtopTheme $TargetTheme
    Switch-NvimTheme $TargetTheme
    Switch-ZedTheme $TargetTheme
    Switch-VSCodeTheme $TargetTheme
    Switch-WindowsTerminalTheme $TargetTheme

    # Windows system appearance
    Switch-WindowsAppearance $TargetTheme

    # Save state
    Save-ThemeState $TargetTheme

    Write-Host ""
    Write-Success "Theme switched to: $TargetTheme"
    Write-Host ""
}

# Auto-switch based on time
function Invoke-AutoSwitch {
    $hour = (Get-Date).Hour
    $currentTheme = Get-CurrentTheme

    if (($hour -ge $DarkStartHour) -or ($hour -lt $DarkEndHour)) {
        $target = "dark"
    } else {
        $target = "light"
    }

    if ($currentTheme -ne $target) {
        Write-Info "Auto-switching theme based on time ($hour:00)"
        Switch-Theme $target
    } else {
        Write-Info "Current theme ($currentTheme) is appropriate for time $hour:00"
    }
}

# Show usage
function Show-Usage {
    @"
Usage: theme-switch.ps1 [COMMAND]

Commands:
    dark            Switch to dark theme
    light           Switch to light theme
    toggle          Toggle between dark and light
    auto            Auto-switch based on time of day
    status          Show current theme
    help            Show this help message

Examples:
    .\theme-switch.ps1 dark        # Switch to dark theme
    .\theme-switch.ps1 toggle      # Toggle current theme
    .\theme-switch.ps1 auto        # Auto-switch based on time

To auto-switch on schedule, create a scheduled task:
    schtasks /create /tn "SoftFocusAutoTheme" /tr "powershell.exe -File `"$PSScriptRoot\theme-switch.ps1`" auto" /sc hourly

"@
}

# Main script
function Main {
    switch ($Command) {
        "dark" {
            Print-Header
            Switch-Theme "dark"
        }
        "light" {
            Print-Header
            Switch-Theme "light"
        }
        "toggle" {
            Print-Header
            $current = Get-CurrentTheme
            if ($current -eq "dark") {
                Switch-Theme "light"
            } else {
                Switch-Theme "dark"
            }
        }
        "auto" {
            Print-Header
            Invoke-AutoSwitch
        }
        "status" {
            $current = Get-CurrentTheme
            Write-Info "Current theme: $current"
        }
        "help" {
            Show-Usage
        }
        default {
            Write-Error-Custom "Unknown command: $Command"
            Write-Host ""
            Show-Usage
            exit 1
        }
    }
}

# Run main
Main
