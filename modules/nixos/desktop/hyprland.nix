{ config, lib, pkgs, inputs, ... }:

{
  # Import Hyprland module from flake
  imports = [ inputs.hyprland.nixosModules.default ];
  
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # Essential packages for Hyprland
  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    swww            # Wallpaper
    swaylock        # Screen locker
    wl-clipboard    # Clipboard
    mako            # Notifications
    grim            # Screenshot functionality
    slurp           # Area selection
    wlogout         # Logout menu
  ];
  
  # XDG Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
  
  # Hardware acceleration
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
  
  # Other required services for a good Wayland experience
  services = {
    gvfs.enable = true;
    tumbler.enable = true;
  };
}
