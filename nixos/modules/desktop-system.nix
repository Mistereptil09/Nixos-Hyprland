{ config, lib, pkgs, ... }:

{
  # System-level Hyprland and Wayland integration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Desktop Portal for screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # SDDM display manager with Wayland enabled
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Global keyboard layout
  services.xserver = {
    xkb = {
      layout = "fr";  # Change to your preferred layout
      variant = "";
    };
  };
  
  console.keyMap = "fr";  # Same as xkb.layout above

  # System-wide session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";    
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Only core system packages needed for Hyprland to function
  environment.systemPackages = with pkgs; [
    libnotify           # Desktop notifications library
    wl-clipboard        # Clipboard utilities for Wayland
    xdg-utils           # Desktop integration utilities 
    xdg-desktop-portal-hyprland # Hyprland portal for screen sharing
  ];
}