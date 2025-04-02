# hosts/minimal/default.nix (system config)
{ nixosProfiles, ... }:

{
  imports = [ nixosProfiles.minimal ];
  
  networking.hostName = "minimal";
  
  # Use mkForce to ensure this definition takes precedence
  user.name = lib.mkForce "antonio";
  initialPassword = lib.mkForce "root";
  user.isNormalUser = true;
  user.extraGroups = [ "wheel" "networkmanager" ];

  # Home-manager imports the user config
  home-manager.users.antonio = import ./home.nix;
}