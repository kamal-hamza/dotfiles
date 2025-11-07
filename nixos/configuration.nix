# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/hyprland.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/fonts.nix
  ];

  # =========================================================================
  # Boot Configuration
  # =========================================================================
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Latest kernel for best hardware support
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # =========================================================================
  # Networking
  # =========================================================================
  networking = {
    hostName = "nixos"; # Change this to your desired hostname
    networkmanager.enable = true;
    # Uncomment if you prefer wireless instead of NetworkManager
    # wireless.enable = true;
  };

  # =========================================================================
  # Time & Locale
  # =========================================================================
  time.timeZone = "America/New_York"; # Change to your timezone

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # =========================================================================
  # Users
  # =========================================================================
  users.users.hkamal = {
    isNormalUser = true;
    description = "Hamza Kamal";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  # =========================================================================
  # Programs
  # =========================================================================
  programs = {
    zsh.enable = true;
    git.enable = true;
    tmux.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    # Enable hyprland
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  # =========================================================================
  # Security
  # =========================================================================
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.hyprlock = {};
  };

  # =========================================================================
  # XDG Portal (needed for screen sharing, file pickers, etc)
  # =========================================================================
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # =========================================================================
  # Environment Variables
  # =========================================================================
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # =========================================================================
  # Nix Settings
  # =========================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # =========================================================================
  # System State Version
  # =========================================================================
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
