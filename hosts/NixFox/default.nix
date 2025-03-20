{ config, pkgs, lib, inputs, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Host-specific configuration
  networking.hostName = hostname;
  
  # Bootloader configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "changeme";
  };
  
  # System state version
  system.stateVersion = "23.11";
}
