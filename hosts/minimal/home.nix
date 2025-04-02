# hosts/minimal/home.nix (user config)
{ homeProfiles, ... }:

{
  imports = [ homeProfiles.minimal ];
  
  # User-specific programs and settings
  programs.git.userEmail = "user@example.com";
}