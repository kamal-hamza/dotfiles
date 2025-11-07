# Home Manager Configuration
# User-level configuration for dotfiles and applications
{ config, pkgs, ... }:

{
  # =========================================================================
  # Home Manager Setup
  # =========================================================================
  home.username = "hkamal";
  home.homeDirectory = "/home/hkamal";
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # =========================================================================
  # Home Packages
  # =========================================================================
  home.packages = with pkgs; [
    # Additional user-specific packages can go here
  ];

  # =========================================================================
  # Git Configuration
  # =========================================================================
  programs.git = {
    enable = true;
    userName = "Hamza Kamal";
    userEmail = "your.email@example.com"; # Change this
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };

  # =========================================================================
  # Zsh Configuration
  # =========================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Use your existing .zshrc from chezmoi
    initExtra = ''
      # Source your custom zsh configuration
      if [ -f "$HOME/.config/zsh/.zshrc" ]; then
        source "$HOME/.config/zsh/.zshrc"
      fi
    '';

    sessionVariables = {
      ZDOTDIR = "$HOME/.config/zsh";
      PATH = "$HOME/.local/bin:$PATH";
    };

    shellAliases = {
      # Basic aliases
      l = "eza --all --icons";
      la = "ls -la";
      cls = "clear";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      # Git shortcuts
      gs = "git status --short";

      # Tools
      t = "tmux a";
      cd = "z";
      yy = "yazi";
      what = "tldr";

      # System
      rebuild = "sudo nixos-rebuild switch";
      rebuild-home = "home-manager switch";
    };

    oh-my-zsh = {
      enable = false; # Using custom configuration
    };
  };

  # =========================================================================
  # Zoxide (smart cd)
  # =========================================================================
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # =========================================================================
  # FZF (fuzzy finder)
  # =========================================================================
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # =========================================================================
  # Bat (better cat)
  # =========================================================================
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  # =========================================================================
  # Eza (better ls)
  # =========================================================================
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  # =========================================================================
  # Tmux Configuration
  # =========================================================================
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";

    extraConfig = ''
      # Source your custom tmux configuration
      if-shell "[ -f ~/.config/tmux/tmux.conf ]" \
        "source-file ~/.config/tmux/tmux.conf"
    '';
  };

  # =========================================================================
  # Neovim Configuration
  # =========================================================================
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Use your existing neovim configuration from chezmoi
    extraConfig = ''
      " Use existing config from ~/.config/nvim
      lua << EOF
      -- Your lazy.nvim config will be loaded from ~/.config/nvim/init.lua
      EOF
    '';
  };

  # =========================================================================
  # Kitty Terminal
  # =========================================================================
  programs.kitty = {
    enable = true;
    # Use your existing kitty configuration from chezmoi
    extraConfig = ''
      # Your kitty config from ~/.config/kitty/kitty.conf will be used
    '';
  };

  # =========================================================================
  # WezTerm Terminal
  # =========================================================================
  # WezTerm uses its own config file at ~/.config/wezterm/wezterm.lua
  # Home Manager will respect your existing configuration

  # =========================================================================
  # Rofi (application launcher)
  # =========================================================================
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    # Use your existing rofi configuration from chezmoi
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      terminal = "wezterm";
      drun-display-format = "{name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 﩯  Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };
  };

  # =========================================================================
  # Yazi File Manager
  # =========================================================================
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  # =========================================================================
  # Lazygit
  # =========================================================================
  programs.lazygit = {
    enable = true;
  };

  # =========================================================================
  # GTK Theme
  # =========================================================================
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # =========================================================================
  # Qt Theme
  # =========================================================================
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # =========================================================================
  # XDG User Directories
  # =========================================================================
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };
  };

  # =========================================================================
  # Hyprland Configuration (symlinked from chezmoi)
  # =========================================================================
  # Hyprland uses ~/.config/hypr/hyprland.conf
  # Your existing configuration will be managed by chezmoi

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    # Use your existing hyprland.conf from chezmoi
    # This tells home-manager to not generate its own config
    extraConfig = ''
      # Your config from ~/.config/hypr/hyprland.conf will be used
      # Managed by chezmoi
    '';
  };

  # =========================================================================
  # Mako Notification Daemon
  # =========================================================================
  services.mako = {
    enable = true;
    # Use your existing mako configuration from chezmoi
    # The config at ~/.config/mako/config will be respected
  };

  # =========================================================================
  # File Associations
  # =========================================================================
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "image/png" = "gimp.desktop";
      "image/jpeg" = "gimp.desktop";
      "image/jpg" = "gimp.desktop";
    };
  };

  # =========================================================================
  # Session Variables
  # =========================================================================
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "wezterm";
    BROWSER = "firefox";

    # XDG Base Directory
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";

    # Path
    PATH = "$HOME/.local/bin:$PATH";
  };

  # =========================================================================
  # Systemd User Services
  # =========================================================================
  systemd.user.services = {
    # Hyprpaper wallpaper daemon
    hyprpaper = {
      Unit = {
        Description = "Hyprpaper wallpaper daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Hypridle idle daemon
    hypridle = {
      Unit = {
        Description = "Hypridle daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Waybar status bar
    waybar = {
      Unit = {
        Description = "Waybar status bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.waybar}/bin/waybar";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Mako notification daemon
    mako = {
      Unit = {
        Description = "Mako notification daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.mako}/bin/mako";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # =========================================================================
  # File Management
  # =========================================================================
  # Chezmoi will manage most dotfiles, but home-manager can complement it
  home.file = {
    # Example: symlink scripts directory
    ".local/bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/chezmoi/dot_local/bin";
  };
}
