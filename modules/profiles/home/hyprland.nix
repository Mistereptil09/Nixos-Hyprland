{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Basic configuration
      monitor = ",preferred,auto,1";
      
      # Startup applications
      exec-once = [
        "waybar"
        "dunst"
        "swww init"
      ];
      
      # Appearance
      decoration = {
        rounding = 10;
        blur.enable = true;
        blur.size = 3;
        blur.passes = 1;
      };
      
      # Animations
      animations.enabled = true;
      
      # Some default workspaces
      workspace = [
        "1, monitor:, default:true"
        "2, monitor:, default:true"
        "3, monitor:, default:true"
      ];
    };
  };
  
  # Hyprland user packages
  home.packages = with pkgs; [
    swww               # Wallpaper
    mako               # Notifications
    wofi               # Application launcher
    waybar             # Status bar
    wl-clipboard       # Clipboard
    hyprpicker         # Color picker
    pamixer            # Volume control
  ];
}
