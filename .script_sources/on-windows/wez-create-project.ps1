<#
.SYNOPSIS
    Advanced Project Creator & WezTerm Session Manager for Windows.
.DESCRIPTION
    This script prompts for a project name, parent directory, and project type,
    then creates the directory, initializes a project template, and opens it
    in a new WezTerm tab or window.
.NOTES
    Author: Gemini
    Version: 1.0
    Requires: fzf, WezTerm, and the build tools for your chosen languages
              (e.g., dotnet, node, python, rustc, go).
#>

#Requires -Modules fzf

# --- Project Initialization Functions ---

# Each function sets up a specific project type.
# They assume the current location is the newly created project root.

function Initialize-DotnetConsole {
    Write-Host "Initializing .NET Console App..."
    dotnet new console
}

function Initialize-ReactVite {
    Write-Host "Initializing React (Vite) App..."
    npm create vite@latest . -- --template react
}

function Initialize-C {
    Write-Host "Creating C boilerplate..."
    @'
#include <stdio.h>

int main() {
    printf("Hello, C World!\\n");
    return 0;
}
'@ | Set-Content -Path "main.c"

    @'
CC=gcc
CFLAGS=-Wall -Wextra -std=c11
TARGET=main

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c

clean:
	rm -f $(TARGET)
'@ | Set-Content -Path "Makefile"
}

function Initialize-Cpp {
    Write-Host "Creating C++ boilerplate..."
    @'
#include <iostream>

int main() {
    std::cout << "Hello, C++ World!" << std::endl;
    return 0;
}
'@ | Set-Content -Path "main.cpp"

    @'
CXX=g++
CXXFLAGS=-Wall -Wextra -std=c++17
TARGET=main

all: $(TARGET)

$(TARGET): main.cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) main.cpp

clean:
	rm -f $(TARGET)
'@ | Set-Content -Path "Makefile"
}

function Initialize-Python {
    Write-Host "Creating Python project with virtual environment..."
    python -m venv .venv
    "@'.venv/','__pycache__/'@" | Set-Content -Path ".gitignore"
    @'
def main():
    print("Hello from Python!")

if __name__ == "__main__":
    main()
'@ | Set-Content -Path "main.py"
}

function Initialize-Node {
    Write-Host "Initializing basic Node.js project..."
    npm init -y | Out-Null
    New-Item -ItemType File -Name "index.js" | Out-Null
    "'node_modules/'" | Set-Content -Path ".gitignore"
}

function Initialize-Go {
    param($ProjectName)
    Write-Host "Initializing Go module..."
    go mod init $ProjectName
    @'
package main

import "fmt"

func main() {
	fmt.Println("Hello, Go World!")
}
'@ | Set-Content -Path "main.go"
}

function Initialize-Rust {
    param($ProjectName)
    Write-Host "Initializing Rust project with Cargo..."
    # Cargo initializes into a new directory, so we create it temporarily and move the contents.
    cargo init --quiet --name $ProjectName "temp_rust_project"
    Get-ChildItem -Path "temp_rust_project" -Force | Move-Item -Destination "."
    Remove-Item -Path "temp_rust_project"
}

function Initialize-Django {
    param($ProjectName)
    Write-Host "Initializing Django project..."
    python -m venv .venv
    # Note: Manual venv activation is needed: .\.venv\Scripts\activate
    & .\.venv\Scripts\pip.exe install django | Out-Null
    & .\.venv\Scripts\django-admin.exe startproject $ProjectName .
    "@'.venv/','db.sqlite3'@" | Set-Content -Path ".gitignore"
}

function Initialize-ExpressJs {
    Write-Host "Initializing Express.js project..."
    npm init -y | Out-Null
    npm install express | Out-Null
    @'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from Express!');
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
'@ | Set-Content -Path "index.js"
    "'node_modules/'" | Set-Content -Path ".gitignore"
}

function Initialize-NestJs {
    Write-Host "Initializing NestJS project..."
    # Nest CLI creates a new folder, so we do the same temp dir trick.
    npx --yes @nestjs/cli new "temp_nest_project" --skip-git --package-manager npm | Out-Null
    Get-ChildItem -Path "temp_nest_project" -Force | Move-Item -Destination "."
    Remove-Item -Path "temp_nest_project"
}

function Initialize-Flask {
    Write-Host "Initializing Flask project..."
    python -m venv .venv
    # Note: Manual venv activation is needed: .\.venv\Scripts\activate
    & .\.venv\Scripts\pip.exe install Flask | Out-Null
    @'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(debug=True)
'@ | Set-Content -Path "app.py"
    "'.venv/'" | Set-Content -Path ".gitignore"
}

function Initialize-Generic {
    Write-Host "Created a generic project folder. No template applied."
}


# --- Main Script Logic ---

# 1. Get Project Name
$ProjectName = Read-Host -Prompt "Project Name"
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    Write-Error "Project name cannot be empty."
    exit 1
}

# 2. Select Parent Directory
$CodeFolder = "$env:USERPROFILE\Code"
$TargetDir = Get-ChildItem -Path $CodeFolder -Directory -Depth 0 |
             Select-Object -ExpandProperty FullName |
             fzf --prompt="Select parent folder: " --height 40% --reverse

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    Write-Host "No directory selected. Exiting."
    exit 1
}

# 3. Select Project Type
$projectTypes = @(
  "dotnet-console",
  "react-vite",
  "expressjs",
  "nestjs",
  "django",
  "flask",
  "python",
  "rust",
  "c",
  "cpp",
  "go",
  "node",
  "generic"
)

$ProjectType = $projectTypes | fzf --prompt="Select project type: " --height 40% --reverse

if ([string]::IsNullOrWhiteSpace($ProjectType)) {
    Write-Host "No project type selected. Exiting."
    exit 1
}

# 4. Create Project Directory & Initialize Template
$ProjectPath = Join-Path -Path $TargetDir -ChildPath $ProjectName

if (Test-Path -Path $ProjectPath) {
    Write-Warning "Directory '$ProjectPath' already exists."
}
else {
    New-Item -Path $ProjectPath -ItemType Directory -Force | Out-Null
    Write-Host "✅ Created project folder at: $ProjectPath"
}

# Change into the new directory to run initialization commands
Set-Location -Path $ProjectPath

Write-Host "⚙️  Initializing a '$ProjectType' project..."

# Call the appropriate function based on the selected project type
switch ($ProjectType) {
    "dotnet-console" { Initialize-DotnetConsole }
    "react-vite"     { Initialize-ReactVite }
    "c"              { Initialize-C }
    "cpp"            { Initialize-Cpp }
    "python"         { Initialize-Python }
    "node"           { Initialize-Node }
    "go"             { Initialize-Go -ProjectName $ProjectName }
    "rust"           { Initialize-Rust -ProjectName $ProjectName }
    "django"         { Initialize-Django -ProjectName $ProjectName }
    "expressjs"      { Initialize-ExpressJs }
    "nestjs"         { Initialize-NestJs }
    "flask"          { Initialize-Flask }
    "generic"        { Initialize-Generic }
    default          {
        Write-Warning "Unknown project type. Creating a generic folder."
        Initialize-Generic
    }
}

Write-Host "🚀 Project setup complete!"

# 5. Open in WezTerm
if ($env:WEZTERM_PANE) {
    # We're already inside WezTerm, so spawn a new tab in the project directory
    wezterm cli spawn --new-tab --cwd $ProjectPath
    Write-Host "Created new WezTerm tab for '$ProjectName'."
}
else {
    # We're not in WezTerm, so start a new instance
    Start-Process wezterm -ArgumentList "start", "--cwd", "$ProjectPath"
    Write-Host "Started WezTerm in '$ProjectPath'."
}
