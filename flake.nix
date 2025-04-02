{
  description = "NixOS + Hyprland Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: 
  let
    lib = nixpkgs.lib;
    
    # Import helper functions
    helpers = import ./common/lib/helpers.nix { inherit lib; };
    
    # Import profiles
    profiles = import ./profiles.nix { 
      inherit lib helpers; 
    };
  in {
    # Make profiles available
    inherit (profiles) nixosProfiles homeProfiles;
    
    # Import all host configurations from hosts.nix
    nixosConfigurations = import ./hosts.nix { 
      inherit self nixpkgs home-manager; 
    };
  };
}