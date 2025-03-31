{ config, lib, pkgs, hostname, username, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/profiles/nixos/desktop.nix
  ];
  
  # Basic system configuration
  networking.hostName = hostname;
  user.name = username;
  
  # Include home configuration
  home-manager.users.${username} = import ./home.nix;
}
