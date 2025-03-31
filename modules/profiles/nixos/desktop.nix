{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  # Enable desktop modules
  config = {
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
        displayManager.gdm.enable = true;
        displayManager.defaultSession = "hyprland";
      };
    };
    
    # Desktop-specific packages
    environment.systemPackages = with pkgs; [
      firefox
    ];
  };
}
