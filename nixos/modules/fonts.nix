# Fonts Configuration
{ config, pkgs, ... }:

{
  # =========================================================================
  # Fonts
  # =========================================================================
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Nerd Fonts - matching your Arch setup
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Meslo"
          "JetBrainsMono"
        ];
      })

      # Standard fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono

      # Microsoft fonts (if needed)
      # corefonts
      # vistafonts

      # Additional programming fonts
      source-code-pro
      hack-font
      ubuntu_font_family
      roboto
      roboto-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "FiraCode Nerd Font" "JetBrainsMono Nerd Font" "Meslo Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Subpixel rendering
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      # Hinting
      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };

      # Antialiasing
      antialias = true;
    };
  };
}
