#!/bin/bash

# --- Helper Functions ---
install_packages() {
  local package_manager_command=$1
  shift
  local packages=("$@")

  if [ ${#packages[@]} -gt 0 ]; then
    echo "Installing: ${packages[*]}"
    eval "$package_manager_command ${packages[*]}"
  else
    echo "No packages to install for this category."
  fi
}

# --- OS Detection ---
os_key=""
package_manager=""
cask_flag="" # For Homebrew GUI apps

# Check for Git Bash / MSYS on Windows first
if [[ "$(uname)" == *"MINGW64"* || "$(uname)" == *"MSYS"* ]]; then
  os_key="windows"
  package_manager="choco install -y"
elif [[ "$(uname)" == "Darwin" ]]; then
  os_key="macos"
  package_manager="brew install"
  cask_flag="--cask"
elif [[ "$(uname)" == "Linux" ]]; then
  os_key="linux"
  if [ -f /etc/debian_version ]; then
    package_manager="sudo apt-get install -y"
  elif [ -f /etc/redhat-release ]; then
    package_manager="sudo dnf install -y"
  elif [ -f /etc/arch-release ]; then
    package_manager="sudo pacman -S --noconfirm"
  else
    echo "Unsupported Linux distribution."
    exit 1
  fi
else
  echo "Unsupported Operating System: $(uname)"
  exit 1
fi

# --- Prerequisite Checks (Chocolatey, jq) ---
if [[ "$os_key" == "windows" ]]; then
  if ! command -v choco &> /dev/null; then
    echo "Chocolatey is not installed. Please install it first by following the instructions at https://chocolatey.org/install"
    echo "You'll need to run a specific command in an Administrative PowerShell."
    exit 1
  fi
fi

if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Attempting to install it now..."
  if [[ "$os_key" == "macos" ]]; then
    brew install jq
  elif [[ "$os_key" == "linux" ]]; then
    ${package_manager% *} jq # Removes flags like -y for a cleaner command
  elif [[ "$os_key" == "windows" ]]; then
    choco install -y jq
  fi

  if ! command -v jq &> /dev/null; then
    echo "Failed to install jq. Please install it manually and run the script again."
    exit 1
  fi
fi

# --- Read JSON and Install Packages ---

# When run by chezmoi, the CHEZMOI_SOURCE_DIR variable is set.
# As a fallback for manual execution, we use the script's own directory.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$SCRIPT_DIR}"
PACKAGES_FILE="${SOURCE_DIR}/packages.json"

# Check if the packages file exists
if [ ! -f "$PACKAGES_FILE" ]; then
    echo "Error: packages.json not found at $PACKAGES_FILE"
    exit 1
fi

echo ""
echo "--- Installing CLI Tools on $os_key ---"
# Use the full path to the packages file
cli_packages=($(jq -r ".cli[].${os_key}" "$PACKAGES_FILE" | grep -v "null"))
install_packages "$package_manager" "${cli_packages[@]}"

echo ""
echo "--- Installing GUI Apps on $os_key ---"
# Use the full path to the packages file
app_packages=($(jq -r ".apps[].${os_key}" "$PACKAGES_FILE" | grep -v "null"))

if [[ "$os_key" == "macos" ]]; then
  # On macOS, add the --cask flag for GUI apps
  install_packages "$package_manager $cask_flag" "${app_packages[@]}"
else
  # Linux and Windows use the same command for CLI and GUI apps
  install_packages "$package_manager" "${app_packages[@]}"
fi

echo ""
echo "Installation complete."
