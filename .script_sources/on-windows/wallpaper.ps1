# ==============================================================================
#
#          Wallpaper Manager for Windows PowerShell
#
#  This script sets desktop wallpaper on Windows
#
# ==============================================================================

param(
  [string]$WallpaperPath
)

# --- Helper Functions ---

function Write-Success {
  param([string]$Message)
  Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
  param([string]$Message)
  Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-InfoMsg {
  param([string]$Message)
  Write-Host "ℹ $Message" -ForegroundColor Cyan
}

# --- Set Wallpaper Function ---

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    
    public const int SPI_SETDESKWALLPAPER = 0x0014;
    public const int SPIF_UPDATEINIFILE = 0x01;
    public const int SPIF_SENDCHANGE = 0x02;
    
    public static void SetWallpaper(string path) {
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    }
}
"@

function Set-Wallpaper {
  param([string]$Path)
    
  if (!(Test-Path $Path)) {
    Write-ErrorMsg "Wallpaper file not found: $Path"
    return $false
  }
    
  $absolutePath = (Resolve-Path $Path).Path
    
  try {
    [Wallpaper]::SetWallpaper($absolutePath)
    Write-Success "Wallpaper set to: $absolutePath"
        
    # Save current wallpaper path
    $configDir = "$env:USERPROFILE\.config\wallpapers"
    if (!(Test-Path $configDir)) {
      New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
        
    $absolutePath | Out-File -FilePath "$configDir\current_wallpaper.txt" -Encoding UTF8
    return $true
  }
  catch {
    Write-ErrorMsg "Failed to set wallpaper: $_"
    return $false
  }
}

# --- Main Script ---

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  🖼️  Wallpaper Manager for Windows" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$wallpaperDir = "$env:USERPROFILE\.config\wallpapers"

# Create wallpaper directory if it doesn't exist
if (!(Test-Path $wallpaperDir)) {
  New-Item -ItemType Directory -Path $wallpaperDir -Force | Out-Null
  Write-InfoMsg "Created wallpaper directory: $wallpaperDir"
}

# If no path provided, show current wallpaper or list available
if ([string]::IsNullOrWhiteSpace($WallpaperPath)) {
  $currentFile = "$wallpaperDir\current_wallpaper.txt"
    
  if (Test-Path $currentFile) {
    $current = Get-Content $currentFile -Raw
    Write-InfoMsg "Current wallpaper: $current"
  }
  else {
    Write-InfoMsg "No current wallpaper set"
  }
    
  Write-Host ""
  Write-Host "Available wallpapers in ${wallpaperDir}:" -ForegroundColor Yellow
  Write-Host ""
    
  $wallpapers = Get-ChildItem -Path $wallpaperDir -Include *.jpg, *.jpeg, *.png, *.bmp -Recurse | Select-Object -ExpandProperty FullName
    
  if ($wallpapers.Count -eq 0) {
    Write-InfoMsg "No wallpapers found. Place images in $wallpaperDir"
    exit 0
  }
    
  for ($i = 0; $i -lt $wallpapers.Count; $i++) {
    $name = Split-Path $wallpapers[$i] -Leaf
    Write-Host "  $($i + 1). $name" -ForegroundColor White
  }
    
  Write-Host ""
  $selection = Read-Host "Select wallpaper number (or press Enter to cancel)"
    
  if ([string]::IsNullOrWhiteSpace($selection)) {
    Write-InfoMsg "Cancelled"
    exit 0
  }
    
  $index = [int]$selection - 1
  if ($index -ge 0 -and $index -lt $wallpapers.Count) {
    $WallpaperPath = $wallpapers[$index]
  }
  else {
    Write-ErrorMsg "Invalid selection"
    exit 1
  }
}

# Set the wallpaper
Set-Wallpaper -Path $WallpaperPath
