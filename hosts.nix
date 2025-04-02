{ self, nixpkgs, home-manager, ... }:

let
  system = "x86_64-linux";
  
  # Host discovery - finds all directories in ./hosts/
  hostNames = builtins.attrNames (builtins.readDir ./hosts);
  
  # Host creation function
  mkHost = hostname: 
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit self hostname;
        inherit (self) nixosProfiles homeProfiles;
      };
      modules = [
        # Core modules
        ./modules/core
        
        # Host-specific config
        ./hosts/${hostname}
        
        # Root hardware config
        ./hardware-configuration.nix
        
        # Home-manager
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { 
            inherit (self) homeProfiles; 
          };
        }
      ];
    };
  
  # Create configurations for all hosts
  nixosConfigs = builtins.listToAttrs (
    map (name: { inherit name; value = mkHost name; }) hostNames
  );
in nixosConfigs