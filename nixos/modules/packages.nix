# All system packages based on your Arch Linux setup
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # =========================================================================
    # Development Tools & Languages
    # =========================================================================
    # Build essentials
    gcc
    clang
    clang-tools
    cmake
    gnumake
    llvm

    # Version control
    git
    lazygit

    # Languages
    go
    perl
    php
    lua-language-server
    stylua
    nodePackages.nodejs
    python3
    python3Packages.pip
    python3Packages.poetry-core
    poetry

    # =========================================================================
    # CLI Tools & Utilities
    # =========================================================================
    bat
    btop
    chezmoi
    curl
    eza
    ffmpeg
    fzf
    tldr
    tmux
    yazi
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autopair

    # File management
    nemo
    wl-clipboard
    xdg-utils

    # System utilities
    htop
    tree
    ripgrep
    fd
    jq
    unzip
    wget

    # =========================================================================
    # Text Editors & IDEs
    # =========================================================================
    neovim
    zed-editor
    vscode

    # =========================================================================
    # Hyprland & Wayland Ecosystem
    # =========================================================================
    # Core Hyprland tools
    hyprland
    hyprpaper
    hyprlock
    hypridle
    hyprcursor

    # Wayland utilities
    waybar
    mako
    rofi-wayland
    wl-clipboard
    wf-recorder
    grim
    slurp
    satty

    # Screenshot tools
    hyprshot

    # Authentication agent
    polkit_gnome

    # =========================================================================
    # Audio & Media
    # =========================================================================
    pipewire
    wireplumber
    pavucontrol
    playerctl

    # =========================================================================
    # Browsers
    # =========================================================================
    firefox
    google-chrome

    # =========================================================================
    # Terminal Emulators
    # =========================================================================
    wezterm
    kitty

    # =========================================================================
    # PDF & Document Viewers
    # =========================================================================
    zathura

    # =========================================================================
    # Graphics & Image Editing
    # =========================================================================
    gimp

    # =========================================================================
    # Networking
    # =========================================================================
    networkmanagerapplet

    # =========================================================================
    # Containerization & Virtualization
    # =========================================================================
    docker
    docker-compose

    # =========================================================================
    # Productivity & Communication
    # =========================================================================
    obsidian

    # =========================================================================
    # AI & LLM Tools
    # =========================================================================
    ollama

    # =========================================================================
    # Development Utilities
    # =========================================================================
    github-desktop

    # =========================================================================
    # System Tools
    # =========================================================================
    brightnessctl
    pamixer
    udiskie

    # =========================================================================
    # Fonts (covered in fonts.nix but included here for reference)
    # =========================================================================
    # Nerd Fonts are in fonts.nix

    # =========================================================================
    # Additional tools from your setup
    # =========================================================================
    # Clipboard manager
    clipman

    # Python packages (pywal)
    python3Packages.pywal

    # LaTeX
    texlive.combined.scheme-full

    # Wayland-specific tools
    xwayland
    qt5.qtwayland
    qt6.qtwayland

    # Theme tools
    lxappearance
    gtk3
    gtk4

    # File picker for browsers
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  # =========================================================================
  # Program-specific configurations
  # =========================================================================
  programs = {
    # Git configuration
    git = {
      enable = true;
      lfs.enable = true;
    };

    # Thunar file manager (alternative to nemo)
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # Enable dconf for GTK applications
    dconf.enable = true;
  };

  # =========================================================================
  # Virtualisation
  # =========================================================================
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };
}
