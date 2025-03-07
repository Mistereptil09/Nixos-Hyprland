{ config, lib, pkgs, ... }:

{
  # User-level utility packages that were moved from system level
  home.packages = with pkgs; [
    # Core Wayland utilities
    waybar              # Status bar for Wayland
    swww                # Wallpaper daemon for Wayland
    mako                # Notification daemon alternative
    
    # Screenshots and screen recording
    grim                # Screenshot utility for Wayland
    slurp               # Region selection tool for screenshots
    wf-recorder         # Screen recording utility
    flameshot           # Screenshot tool
    
    # Lock screen
    swaylock-effects    # Screen locker with effects
  ];
  
  # Configure screenshots with grim and slurp
  programs.grim = {
    enable = true;
  };
}
