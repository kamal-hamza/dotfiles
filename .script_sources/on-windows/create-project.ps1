# ==============================================================================
#
#          Advanced Project Creator for Windows PowerShell
#
#  This script prompts for a project name, parent directory, and project type,
#  then creates the directory, initializes a project template
#
#  Dependencies: .NET, Node.js, Python, Rust, Go (depending on project type)
#
# ==============================================================================

param(
  [string]$ProjectName,
  [string]$ParentDir,
  [string]$ProjectType
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

# --- Project Initialization Functions ---

function Initialize-DotNetConsole {
  Write-InfoMsg "Initializing .NET Console App..."
  dotnet new console
  Write-Success ".NET Console project initialized"
}

function Initialize-ReactVite {
  Write-InfoMsg "Initializing React (Vite) App..."
  npm create vite@latest . -- --template react
  Write-Success "React (Vite) project initialized"
}

function Initialize-CProject {
  Write-InfoMsg "Creating C boilerplate..."
    
  @'
#include <stdio.h>

int main() {
    printf("Hello, C World!\n");
    return 0;
}
'@ | Out-File -FilePath "main.c" -Encoding UTF8
    
  @'
CC=gcc
CFLAGS=-Wall -Wextra -std=c11
TARGET=main.exe

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c

clean:
	del /Q $(TARGET)
'@ | Out-File -FilePath "Makefile" -Encoding UTF8
    
  Write-Success "C project boilerplate created"
}

function Initialize-CppProject {
  Write-InfoMsg "Creating C++ boilerplate..."
    
  @'
#include <iostream>

int main() {
    std::cout << "Hello, C++ World!" << std::endl;
    return 0;
}
'@ | Out-File -FilePath "main.cpp" -Encoding UTF8
    
  @'
CXX=g++
CXXFLAGS=-Wall -Wextra -std=c++17
TARGET=main.exe

all: $(TARGET)

$(TARGET): main.cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) main.cpp

clean:
	del /Q $(TARGET)
'@ | Out-File -FilePath "Makefile" -Encoding UTF8
    
  Write-Success "C++ project boilerplate created"
}

function Initialize-PythonProject {
  Write-InfoMsg "Creating Python project with virtual environment..."
  python -m venv .venv
    
  @"
.venv/
__pycache__/
*.pyc
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
    
  @'
def main():
    print("Hello from Python!")

if __name__ == "__main__":
    main()
'@ | Out-File -FilePath "main.py" -Encoding UTF8
    
  Write-Success "Python project initialized with venv"
}

function Initialize-NodeProject {
  Write-InfoMsg "Initializing basic Node.js project..."
  npm init -y
    
  @'
console.log("Hello from Node.js!");
'@ | Out-File -FilePath "index.js" -Encoding UTF8
    
  Write-Success "Node.js project initialized"
}

function Initialize-RustProject {
  Write-InfoMsg "Initializing Rust project..."
  cargo init
  Write-Success "Rust project initialized with Cargo"
}

function Initialize-GoProject {
  Write-InfoMsg "Initializing Go module..."
  $moduleName = Read-Host "Enter module name (e.g., github.com/user/project)"
  if ([string]::IsNullOrWhiteSpace($moduleName)) {
    $moduleName = "example.com/hello"
  }
    
  go mod init $moduleName
    
  @'
package main

import "fmt"

func main() {
    fmt.Println("Hello from Go!")
}
'@ | Out-File -FilePath "main.go" -Encoding UTF8
    
  Write-Success "Go project initialized"
}

function Initialize-DotNetWebAPI {
  Write-InfoMsg "Initializing .NET Web API..."
  dotnet new webapi
  Write-Success ".NET Web API project initialized"
}

function Initialize-NextJS {
  Write-InfoMsg "Initializing Next.js App..."
  npx create-next-app@latest . --use-npm
  Write-Success "Next.js project initialized"
}

function Initialize-EmptyProject {
  Write-InfoMsg "Creating empty project with README..."
  @"
# $ProjectName

Created on $(Get-Date -Format 'yyyy-MM-dd')

## Description

Add your project description here.
"@ | Out-File -FilePath "README.md" -Encoding UTF8
    
  Write-Success "Empty project created"
}

# --- Project Type Selection ---

$ProjectTypes = @{
  "1"  = @{ Name = "C"; Function = { Initialize-CProject } }
  "2"  = @{ Name = "C++"; Function = { Initialize-CppProject } }
  "3"  = @{ Name = "Python"; Function = { Initialize-PythonProject } }
  "4"  = @{ Name = "Node.js"; Function = { Initialize-NodeProject } }
  "5"  = @{ Name = "Rust"; Function = { Initialize-RustProject } }
  "6"  = @{ Name = "Go"; Function = { Initialize-GoProject } }
  "7"  = @{ Name = ".NET Console"; Function = { Initialize-DotNetConsole } }
  "8"  = @{ Name = ".NET Web API"; Function = { Initialize-DotNetWebAPI } }
  "9"  = @{ Name = "React (Vite)"; Function = { Initialize-ReactVite } }
  "10" = @{ Name = "Next.js"; Function = { Initialize-NextJS } }
  "11" = @{ Name = "Empty"; Function = { Initialize-EmptyProject } }
}

# --- Main Script ---

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  🚀 Project Creator for Windows" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Get project name if not provided
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
  $ProjectName = Read-Host "Enter project name"
  if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    Write-ErrorMsg "Project name cannot be empty"
    exit 1
  }
}

# Get parent directory if not provided
if ([string]::IsNullOrWhiteSpace($ParentDir)) {
  $ParentDir = Read-Host "Enter parent directory (default: $HOME\Projects)"
  if ([string]::IsNullOrWhiteSpace($ParentDir)) {
    $ParentDir = "$HOME\Projects"
  }
}

# Ensure parent directory exists
if (!(Test-Path $ParentDir)) {
  New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
  Write-Success "Created parent directory: $ParentDir"
}

# Get project type if not provided
if ([string]::IsNullOrWhiteSpace($ProjectType)) {
  Write-Host ""
  Write-Host "Available Project Types:" -ForegroundColor Yellow
  Write-Host ""
  foreach ($key in $ProjectTypes.Keys | Sort-Object) {
    $type = $ProjectTypes[$key]
    Write-Host "  $key. $($type.Name)" -ForegroundColor White
  }
  Write-Host ""
    
  $ProjectType = Read-Host "Select project type (1-11)"
}

# Validate project type
if (!$ProjectTypes.ContainsKey($ProjectType)) {
  Write-ErrorMsg "Invalid project type: $ProjectType"
  exit 1
}

# Create project directory
$ProjectPath = Join-Path $ParentDir $ProjectName
if (Test-Path $ProjectPath) {
  Write-ErrorMsg "Project directory already exists: $ProjectPath"
  exit 1
}

New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
Write-Success "Created project directory: $ProjectPath"

# Change to project directory
Set-Location $ProjectPath

# Initialize project
$selectedType = $ProjectTypes[$ProjectType]
Write-Host ""
Write-InfoMsg "Initializing $($selectedType.Name) project..."
Write-Host ""

try {
  & $selectedType.Function
  Write-Host ""
  Write-Success "Project '$ProjectName' created successfully!"
  Write-Host ""
  Write-InfoMsg "Project location: $ProjectPath"
  Write-Host ""
  Write-Host "To open in VS Code, run:" -ForegroundColor Yellow
  Write-Host "  code $ProjectPath" -ForegroundColor White
  Write-Host ""
}
catch {
  Write-ErrorMsg "Failed to initialize project: $_"
  exit 1
}
