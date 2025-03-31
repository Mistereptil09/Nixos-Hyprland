{ lib, self, system, nixpkgs, home-manager, inputs, ... }:

let
  defaultUser = "antonio";
  
  # Simplified host creation function - no automatic profile imports
  mkHost = { hostname, username ? defaultUser }: 
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { 
        inherit inputs system lib;
        nixosProfiles = self.nixosProfiles;
        homeProfiles = self.homeProfiles;
        currentUsername = username;
      };
      modules = [
        # Hardware and main configuration
        ./hosts/${hostname}/hardware-configuration.nix
        ./hosts/${hostname}/default.nix
        
        # Home-manager module
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs system; 
            homeProfiles = self.homeProfiles;
            username = username;
          };
          home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
        }
      ];
    };
in
{
  # Host configurations - simpler without profile lists
  hosts = {
    # Minimal configuration
    minimal = mkHost {
      hostname = "minimal";
      username = defaultUser;
    };
    
    # Add other hosts as needed
    # hyprland_desktop = mkHost {
    #   hostname = "hyprland_desktop";
    #   username = defaultUser;
    # };
  };
}
