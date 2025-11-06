# ==============================================================================
#
#          Lock Screen Script for Windows PowerShell
#
#  This script locks the Windows screen
#
# ==============================================================================

# Lock the workstation
Write-Host "🔒 Locking screen..." -ForegroundColor Cyan

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class LockScreen {
    [DllImport("user32.dll")]
    public static extern bool LockWorkStation();
}
"@

[LockScreen]::LockWorkStation()
