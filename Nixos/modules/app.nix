{ config, lib, pkgs, ... }:

{
  # Applications for your workflow
  environment.systemPackages = with pkgs; [
    # Terminal and shell
    kitty              # GPU-accelerated terminal emulator with extensive features
    oh-my-zsh          # Framework for managing ZSH configuration with themes and plugins
    
    # Browsers
    firefox            # Privacy-focused web browser from Mozilla
    # google-chrome      # Google's web browser with Google account integration
    
    # File management
    thunar             # Fast and lightweight file manager from XFCE
    xfce.thunar-archive-plugin # Archive management plugin for Thunar
    
    # Media
    mpv                # Minimalist and customizable video player
    spotify            # Music streaming service client
    
    # Office and productivity
    libreoffice        # Full office suite compatible with Microsoft formats
    zathura            # Minimalistic document viewer with VI-style keybindings
    
    # System monitoring
    btop               # Modern resource monitor with advanced visualization
    
    # Communication
    discord            # All-in-one voice, video and text communication platform
    slack              # Team messaging and collaboration platform
    
    # Note: Utility packages (flameshot, pavucontrol, blueman) moved to modules/utils.nix
  ];

  # Enable Flatpak for additional applications
  services.flatpak.enable = true;

  # Configure default applications
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  # Font configuration
  fonts.packages = with pkgs; [
    noto-fonts          # Google's font family with extensive Unicode coverage
    noto-fonts-cjk      # CJK (Chinese, Japanese, Korean) fonts
    noto-fonts-emoji    # Emoji font from Google
    liberation_ttf      # Fonts metrically compatible with Arial, Times New Roman
    fira-code           # Monospaced font with programming ligatures
    fira-code-symbols   # Symbols for the Fira Code font
    mplus-outline-fonts.githubRelease # Japanese font family
    jetbrains-mono      # Developer-oriented monospaced font
    font-awesome        # Icon font used in many web projects
  ];
}