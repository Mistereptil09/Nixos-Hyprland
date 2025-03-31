{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hyprland
  ];
  
  # Enable desktop modules
  modules.hyprland.enable = true;
  
  # Common desktop settings
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
  ];
  
  # Enable common desktop services
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
        defaultSession = "hyprland";
      };
    };
  };
  
  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    firefox
    vlc
    gnome.nautilus
    gnome.eog
    pavucontrol
    networkmanagerapplet
  ];
}
