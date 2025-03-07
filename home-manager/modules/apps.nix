{ config, lib, pkgs, ... }:

{
  # Applications moved from system level to home-manager
  home.packages = with pkgs; [
    # Office and productivity
    libreoffice
    zathura
    
    # File management
    thunar
    xfce.thunar-archive-plugin
    
    # System monitoring
    btop
    
    # Screenshot and media tools
    flameshot
    grim
    slurp
    wf-recorder
    
    # Password management
    keepassxc
  ];
  
  # Configure file associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
    };
  };
  
  # Terminal configuration
  programs.kitty = {
    enable = true;
    theme = "Tokyo Night";
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
    settings = {
      confirm_os_window_close = 0;
    };
  };
  
  # Configure zathura
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      recolor-keephue = true;
    };
  };
}
