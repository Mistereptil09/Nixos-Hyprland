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
  # Don't directly enable pulseaudio as we use pipewire in desktop profile
  # hardware.pulseaudio.enable = true; <- removing this
  
  # Create any directories needed for your configuration
  system.activationScripts.makeDirs = {
    text = ''
      mkdir -p /home/antonio/.config
    '';
    deps = [];
  };
}
