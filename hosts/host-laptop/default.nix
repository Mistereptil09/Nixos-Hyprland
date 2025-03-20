{ config, pkgs, lib, inputs, username, hostname, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    
    # Common configurations that should apply to this host
    ../common/optional/hyprland.nix
    ../common/optional/pipewire.nix
    ../common/optional/fonts.nix
  ];

  # Basic system configuration
  networking.hostName = hostname;
  
  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "changeme";
  };

  # System packages specific to this host
  environment.systemPackages = with pkgs; [
    # Add any host-specific packages
    git
    vim
    wget
    curl
  ];

  # Enable basic services
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
    
    # Other services
    printing.enable = true;
  };

  # System state version
  system.stateVersion = "23.11";
}
