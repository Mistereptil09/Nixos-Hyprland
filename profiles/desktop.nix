{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  # Desktop-specific configurations
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
    
    # Essential desktop services
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
  
  # Common desktop packages
  environment.systemPackages = with pkgs; [
    # GUI utilities
    firefox
    alacritty
    thunar
    pavucontrol
    
    # CLI utilities
    git
    wget
    curl
    ripgrep
    htop
  ];
  
  # Enable some needed fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
  ];
}
