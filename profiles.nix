{ lib, helpers, ... }:

{
  # Use helpers to automatically import all profiles
  nixosProfiles = helpers.importDirToAttrs ./modules/profiles/nixos;
  
  # Home-manager profiles with automatic import
  homeProfiles = helpers.importDirToAttrs ./modules/profiles/home;
}
