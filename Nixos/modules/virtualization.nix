{ config, lib, pkgs, ... }:

{
  # Enable virtualization
  virtualisation = {
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Allows podman to be used as a drop-in replacement for docker
    };
  };
  
  environment.systemPackages = with pkgs; [
    virt-manager      # Desktop interface for managing virtual machines through libvirt
    podman-compose    # Docker Compose alternative for Podman with similar functionality
  ];
  
  # Add user to libvirt group
  users.users.YOUR_USERNAME.extraGroups = [ "libvirtd" ];
}
