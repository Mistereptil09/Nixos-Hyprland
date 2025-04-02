# hosts/minimal/default.nix (system config)
{ nixosProfiles, ... }:

{
  imports = [ nixosProfiles.minimal ];
  
  networking.hostName = "minimal";
  
  # User is configured via modules.core.user
  user.name = "antonio";
  
  # Home-manager imports the user config
  home-manager.users.antonio = import ./home.nix;
}