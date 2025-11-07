# NixOS Quickstart - Chezmoi Automated Installation

## 🚀 The Simplest Way to Install NixOS with Hyprland

This guide will get you from a NixOS ISO to a fully configured Hyprland system in **one command**.

## 📋 What You'll Get

- ✅ NixOS with latest kernel
- ✅ Hyprland Wayland compositor
- ✅ All your development tools (Neovim, Zed, VS Code, etc.)
- ✅ Complete terminal setup (Zsh, Tmux, Yazi, etc.)
- ✅ Docker, Ollama, and development environment
- ✅ Your dotfiles automatically applied

## 🎯 Prerequisites

1. **Boot into NixOS Live ISO** (download from [nixos.org](https://nixos.org/download.html))
2. **Internet connection**
3. **~30 minutes** for installation

## 🔥 The One-Command Installation

### Step 1: Boot the ISO

Boot your computer from the NixOS USB drive.

### Step 2: Connect to Internet

#### For Ethernet
Should work automatically. Test with:
```bash
ping -c 3 google.com
```

#### For WiFi
```bash
sudo systemctl start wpa_supplicant
wpa_cli
```

Then in wpa_cli:
```
add_network
set_network 0 ssid "YourWiFiName"
set_network 0 psk "YourPassword"
enable_network 0
quit
```

Test connection:
```bash
ping -c 3 google.com
```

### Step 3: Run Chezmoi

This single command does everything:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kamal-hamza
```

**Replace `kamal-hamza` with your GitHub username** if you've forked this repo.

### Step 4: Follow the Prompts

The installer will ask you:
- **Hostname** (e.g., "nixos", "laptop", "mypc")
- **Username** (your login name)
- **Full Name** (for git commits)
- **Email** (for git commits)
- **Timezone** (e.g., "America/New_York", "Europe/London")
- **GPU Type** (Intel / NVIDIA / AMD)
- **Disk** (which disk to install to - **THIS WILL BE ERASED!**)

### Step 5: Confirm and Install

The script will:
1. ✅ Partition your disk automatically (GPT with EFI boot)
2. ✅ Generate hardware configuration
3. ✅ Install NixOS with all packages
4. ✅ Configure Hyprland
5. ✅ Set up your user account
6. ✅ Apply all your dotfiles

**Time: 10-30 minutes** depending on internet speed.

### Step 6: Reboot

The system will reboot automatically, or you can type:
```bash
reboot
```

## 🎮 After Installation

### First Login

1. You'll see the **greetd** login screen
2. Enter your **username** and **password**
3. Hyprland starts automatically! 🎉

### Essential Keybindings

| Action | Keybinding |
|--------|------------|
| Open Terminal | `SUPER + Q` |
| Open Browser | `SUPER + E` |
| Open Editor | `SUPER + W` |
| App Launcher | `SUPER + SPACE` |
| File Manager | `SUPER + R` |
| Close Window | `SUPER + X` |
| Fullscreen | `SUPER + F` |
| Float Window | `SUPER + V` |

**SUPER** = Windows key / Command key

### Moving Around

| Action | Keybinding |
|--------|------------|
| Focus Left | `SUPER + H` or `SUPER + ←` |
| Focus Right | `SUPER + L` or `SUPER + →` |
| Focus Up | `SUPER + K` or `SUPER + ↑` |
| Focus Down | `SUPER + J` or `SUPER + ↓` |
| Move Window | `SUPER + SHIFT + H/J/K/L` |
| Resize Window | `SUPER + CTRL + H/J/K/L` |

### Workspaces

| Action | Keybinding |
|--------|------------|
| Switch to Workspace 1-10 | `SUPER + 1-0` |
| Move to Workspace | `SUPER + SHIFT + 1-0` |
| Scratchpad | `SUPER + S` |

## 🔧 Next Steps

### Update Your Dotfiles

```bash
# Pull latest changes
chezmoi update

# Apply changes
chezmoi apply
```

### Rebuild System

After editing `/etc/nixos/configuration.nix`:

```bash
sudo nixos-rebuild switch
```

### Update Packages

```bash
# Update flake inputs
cd /etc/nixos
sudo nix flake update

# Rebuild with updates
sudo nixos-rebuild switch
```

### Install Additional Packages

Two ways to install packages:

#### 1. System-wide (Persistent)

Edit `/etc/nixos/modules/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your packages
  package-name
];
```

Then