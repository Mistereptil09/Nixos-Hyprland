{ config, lib, pkgs, ... }:

{
  # Enable Hyprland and Wayland support
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

  # Session variables for Hyprland and Wayland
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

  # Additional Wayland utilities
  environment.systemPackages = with pkgs; [
    grimblast         # Enhanced screenshot tool combining grim, slurp and other tools
    hyprpicker        # Color picker tool for Hyprland
    swayidle          # Idle management daemon for Wayland
    kanshi            # Dynamic display configuration tool (auto-configures displays)
    xdg-utils         # Desktop integration utilities for opening files/URLs with correct apps
  ];
}