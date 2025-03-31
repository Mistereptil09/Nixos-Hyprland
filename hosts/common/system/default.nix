{ config, lib, pkgs, ... }:

{
  # Common system configuration for all hosts
  
  # Basic system settings
  users.users.antonio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "changeme";
  };
  
  # Setup sudo
  security.sudo.wheelNeedsPassword = false;
  
  # Networking
  networking.networkmanager.enable = true;
  
  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  
  # Create any directories needed for your configuration
  system.activationScripts.makeDirs = {
    text = ''
      mkdir -p /home/antonio/.config
    '';
    deps = [];
  };
}
