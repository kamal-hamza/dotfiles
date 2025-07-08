#!/bin/bash

# NOTE: 'set -e' is intentionally omitted to allow the script to continue
# even if a single package installation fails.

# --- Configuration ---
# Shell colors for logging
readonly C_RESET='\033[0m'
readonly C_RED='\033[0;31m'
readonly C_GREEN='\033[0;32m'
readonly C_BLUE='\033[0;34m'
readonly C_YELLOW='\033[0;33m'

# --- Helper Functions ---
log_info() {
    echo -e "${C_BLUE}INFO:${C_RESET} $1"
}

log_success() {
    echo -e "${C_GREEN}SUCCESS:${C_RESET} $1"
}

log_warn() {
    echo -e "${C_YELLOW}WARN:${C_RESET} $1"
}

log_error() {
    echo -e "${C_RED}ERROR:${C_RESET} $1" >&2
}

# --- OS & Package Manager Detection ---
OS=""
OS_KEY=""
PKG_MANAGER_CMD=""
PKG_MANAGER_APPS_CMD=""
SUDO_CMD=""

detect_os() {
    log_info "Detecting operating system..."
    case "$(uname -s)" in
        Linux*)
            if [ -f /etc/arch-release ]; then
                OS="Arch"
                OS_KEY="linux"
                PKG_MANAGER_CMD="pacman -S --noconfirm"
                PKG_MANAGER_APPS_CMD="pacman -S --noconfirm"
                SUDO_CMD="sudo"
            else
                log_error "Unsupported Linux distribution. Only Arch Linux is supported by this script."
                exit 1 # This is a fatal error, so we exit manually.
            fi
            ;;
        Darwin*)
            OS="macOS"
            OS_KEY="macos"
            PKG_MANAGER_CMD="brew install"
            PKG_MANAGER_APPS_CMD="brew install --cask"
            SUDO_CMD=""
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS="Windows"
            OS_KEY="windows"
            PKG_MANAGER_CMD="winget install -e --id"
            PKG_MANAGER_APPS_CMD="winget install -e --id"
            SUDO_CMD=""
            ;;
        *)
            log_error "Unsupported operating system."
            exit 1 # This is a fatal error.
            ;;
    esac
    log_success "Detected OS: ${OS}"
}

# --- Prerequisite Installation ---

# Function to check for and install Homebrew on macOS
install_homebrew() {
    if [[ "$OS" != "macOS" ]]; then
        return
    fi

    if command -v brew &>/dev/null; then
        log_info "Homebrew is already installed."
        log_info "Updating Homebrew..."
        brew update
    else
        log_info "Homebrew not found. Installing Homebrew..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            log_error "Failed to install Homebrew. The script cannot continue."
            exit 1
        fi
        # Add Homebrew to PATH for the current script session
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed."
    fi
}

# Function to check for and install jq
install_jq() {
    if command -v jq &>/dev/null; then
        log_info "jq is already installed."
        return
    fi

    log_info "jq not found. Installing jq..."
    local install_cmd
    if [[ "$OS" == "macOS" ]]; then
        install_cmd="brew install jq"
    elif [[ "$OS" == "Arch" ]]; then
        install_cmd="sudo pacman -S --noconfirm jq"
    elif [[ "$OS" == "Windows" ]]; then
        install_cmd="winget install -e --id jqlang.jq"
    fi

    if ! $install_cmd; then
        log_error "Failed to install jq. The script cannot continue."
        exit 1
    fi
    log_success "jq installed."
}


# --- Main Installation Logic ---

# Reads packages.json and installs packages for the detected OS
# $1: Category ("cli" or "apps")
# $2: Install command (e.g., "brew install" or "winget install -e --id")
install_packages() {
    local category="$1"
    local install_cmd="$2"
    local json_file="packages.json" # Assumes script is run from chezmoi root

    if [ ! -f "$json_file" ]; then
        log_error "'$json_file' not found. This script must be run from the root of your chezmoi repository."
        exit 1
    fi

    log_info "Processing '$category' packages from $json_file..."

    jq -r --arg os_key "$OS_KEY" ".${category}[] | select(.\($os_key) != null) | .\($os_key)" "$json_file" | while IFS= read -r package_name; do
        if [ -z "$package_name" ]; then
            continue
        fi

        # Handle special cases that shouldn't be installed by a package manager
        if [[ "$package_name" == "nvm" || "$package_name" == "pyenv" || "$package_name" == *"-win" ]]; then
            log_warn "Skipping '$package_name'. It requires a separate installation script or manual setup."
            continue
        fi

        log_info "Installing ${package_name}..."
        # This 'if/else' block now handles failures gracefully without exiting the script.
        if $SUDO_CMD $install_cmd $package_name; then
            log_success "Successfully installed ${package_name}."
        else
            log_error "Failed to install '${package_name}'. It may be unavailable in the repository. Skipping."
        fi
    done
}


# --- Main Execution ---
main() {
    detect_os
    install_homebrew
    install_jq

    # Install CLI packages
    install_packages "cli" "$PKG_MANAGER_CMD"

    # Install App (GUI) packages
    install_packages "apps" "$PKG_MANAGER_APPS_CMD"

    log_success "All packages processed successfully!"
}

# Run the main function
main "$@"
