{ config, lib, pkgs, ... }:

{
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };
  
  # Enable mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
