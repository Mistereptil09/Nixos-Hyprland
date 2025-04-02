# profiles.nix
{ lib, helpers, ... }:

let
  # Import regular profiles automatically
  nixosProfiles = helpers.importDirToAttrs ./modules/profiles/nixos;
  homeProfiles = helpers.importDirToAttrs ./modules/profiles/home;
in {
  # Make all profiles available
  inherit nixosProfiles homeProfiles;
  
  # Create meta-profiles that combine multiple profiles
  metaProfiles = {
    fullWorkstation = {
      system = [
        nixosProfiles.desktop
        nixosProfiles.development
      ];
      user = [
        homeProfiles.desktop
        homeProfiles.development
      ];
    };
  };
}