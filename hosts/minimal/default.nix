{ nixosProfiles, lib, ... }:

{
  imports = [ nixosProfiles.minimal ];
  
  networking.hostName = "minimal";
  
  # Fix: proper function arguments and attribute structure
  user = {
    name = lib.mkForce "antonio";
    initialPassword = lib.mkForce "root";
  };  

  # Home-manager imports the user config
  home-manager.users.antonio = import ./home.nix;
}