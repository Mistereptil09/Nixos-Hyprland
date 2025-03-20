{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  # Minimal configuration without GUI
  # Useful for servers or minimal systems
  
  # Limited set of packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
  ];
  
  # Disable unnecessary services
  services = {
    xserver.enable = false;
    printing.enable = false;
  };
  
  # Lightweight system configuration
  boot.tmp.cleanOnBoot = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
