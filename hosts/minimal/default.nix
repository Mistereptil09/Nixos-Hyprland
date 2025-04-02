# hosts/minimal/default.nix (system config)
{ nixosProfiles, ... }:

{
  imports = [ nixosProfiles.minimal ];
  
  networking.hostName = "minimal";
  
<<<<<<< HEAD
  # User is configured via modules.core.user
  user.name = "antonio";
  
=======
  # Use mkForce to ensure this definition takes precedence
  user.name = lib.mkForce "antonio";
  initialPassword = lib.mkForce "root";
  user.isNormalUser = true;
  user.extraGroups = [ "wheel" "networkmanager" ];

>>>>>>> 9bbf011 (name priorities love to see it...)
  # Home-manager imports the user config
  home-manager.users.antonio = import ./home.nix;
}