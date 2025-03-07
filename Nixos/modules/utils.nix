{ config, lib, pkgs, ... }:

{
  # Utility packages common across configurations
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    waybar              # Status bar for Wayland
    swww                # Wallpaper daemon for Wayland
    mako                # Notification daemon alternative
    libnotify           # Desktop notifications library
    wl-clipboard        # Clipboard utilities for Wayland
    cliphist            # Clipboard history manager
    wofi                # Wayland-native launcher
    swaybg              # Dynamic wallpaper manager for Wayland

    # Theming and configuration tools
    nwg-look            # GTK settings editor
    qt5ct               # Qt5 configuration tool
    lxappearance        # GTK theme switcher
    xfce.thunar-archive-plugin # Archive management plugin for Thunar

    # Screenshots and screen recording
    grim                # Screenshot utility for Wayland
    slurp               # Region selection tool for screenshots
    wf-recorder         # Screen recording utility

    # Lock screen
    swaylock-effects    # Screen locker with effects

    # Audio and brightness controls
    pamixer             # PulseAudio mixer CLI
    brightnessctl       # Brightness control

    # Additional utilities
    wlsunset            # Gamma adjustments for Wayland
    networkmanagerapplet# Network manager system tray applet
    flameshot           # Screenshot tool
    pavucontrol         # PulseAudio volume control GUI
    blueman             # Bluetooth manager
    duf                 # Disk usage utility with better UI
    htop                # Interactive process viewer
  ];
}
