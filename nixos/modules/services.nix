# System Services Configuration
{ config, pkgs, ... }:

{
  # =========================================================================
  # Audio - PipeWire
  # =========================================================================
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
  };

  # Disable PulseAudio (using PipeWire instead)
  hardware.pulseaudio.enable = false;

  # =========================================================================
  # Networking
  # =========================================================================
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  networking.networkmanager.enable = true;

  # =========================================================================
  # Bluetooth
  # =========================================================================
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # =========================================================================
  # Printing (CUPS)
  # =========================================================================
  services.printing.enable = true;

  # =========================================================================
  # Power Management
  # =========================================================================
  services.power-profiles-daemon.enable = true;

  # TLP for laptop power management (optional, comment out if using power-profiles-daemon)
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #   };
  # };

  # =========================================================================
  # USB Automounting
  # =========================================================================
  services.udisks2.enable = true;
  services.devmon.enable = true;
  services.gvfs.enable = true;

  # =========================================================================
  # Systemd Services
  # =========================================================================
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
  # Ollama Service (AI/LLM)
  # =========================================================================
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Change to "rocm" for AMD GPUs, or null for CPU-only
  };

  # =========================================================================
  # Docker
  # =========================================================================
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # =========================================================================
  # DBus
  # =========================================================================
  services.dbus.enable = true;

  # =========================================================================
  # Flatpak (optional package manager)
  # =========================================================================
  services.flatpak.enable = true;

  # =========================================================================
  # Firmware Updates
  # =========================================================================
  services.fwupd.enable = true;

  # =========================================================================
  # Trim for SSDs
  # =========================================================================
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
}
