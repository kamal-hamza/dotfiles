# Hyprland Wayland Compositor Configuration
{ config, pkgs, ... }:

{
  # =========================================================================
  # Hyprland Configuration
  # =========================================================================
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # =========================================================================
  # Display Manager - ly (console display manager)
  # =========================================================================
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Alternative: If you prefer ly (from your Arch setup)
  # Note: ly is not in nixpkgs by default, using greetd as alternative
  # You can enable SDDM or GDM if you prefer a graphical login manager:
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.wayland.enable = true;

  # =========================================================================
  # XDG Desktop Portal (for screen sharing, file pickers, etc.)
  # =========================================================================
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # =========================================================================
  # Security & Authentication
  # =========================================================================
  security.polkit.enable = true;

  # Polkit authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # =========================================================================
  # Environment Setup for Hyprland
  # =========================================================================
  environment.sessionVariables = {
    # Wayland
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # Qt
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";

    # GTK
    GDK_BACKEND = "wayland,x11";

    # Mozilla/Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # Electron apps
    NIXOS_OZONE_WL = "1";

    # Clutter
    CLUTTER_BACKEND = "wayland";

    # Cursor
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";

    # Hardware cursor workaround (if needed)
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # =========================================================================
  # Hyprland-specific packages
  # =========================================================================
  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    hyprland
    hyprpaper
    hyprlock
    hypridle
    hyprcursor
    hyprshot

    # Wayland tools
    waybar
    mako
    rofi-wayland
    wl-clipboard
    wf-recorder
    grim
    slurp
    satty
    swaylock
    swayidle

    # Notification daemon
    libnotify

    # Screen sharing
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    # Additional utilities
    wlr-randr
    wlsunset
    wlogout

    # Clipboard manager
    clipman
    wl-clip-persist

    # Authentication
    polkit_gnome

    # Qt/GTK theming
    qt5ct
    qt6ct
    lxappearance
  ];
}
