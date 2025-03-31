{
  description = "NixOS configuration with Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      
      # Get current user information
      username = builtins.getEnv "USER";
      # Default to "antonio" if USER env var is empty (e.g., when run with sudo)
      defaultUser = if username != "" then username else "antonio";
      
      # Import helper functions
      helpers = import ./common/lib/helpers.nix { inherit lib; };
      
      # Function to create a host configuration
      mkHost = { hostname, profiles ? [], homeProfiles ? [], username ? defaultUser }: 
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { 
            inherit inputs system lib;
            profiles = self.nixosProfiles;
            homeProfiles = self.homeProfiles;
            currentUsername = username;
          };
          modules = [
            # Import hardware configuration
            ./hosts/${hostname}/hardware.nix
            
            # Import the host's main configuration
            ./hosts/${hostname}/default.nix
            
            # Add home-manager module
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs system; 
                profiles = self.homeProfiles;
                username = username;
              };
              home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
            }
            
            # Import all requested system profiles
            ({...}: { imports = map (profile: self.nixosProfiles.${profile}) profiles; })
          ];
        };
    in
    {
      # NixOS system profiles
      nixosProfiles = helpers.importDirToAttrs ./modules/profiles/nixos;
      
      # Home-manager user profiles
      homeProfiles = helpers.importDirToAttrs ./modules/profiles/home;
      
      # Individual modules (for direct importing)
      nixosModules = helpers.importDirToAttrs ./modules;
      
      # Host configurations
      nixosConfigurations = {
        # Hyprland minimal laptop - uses profiles instead of direct module imports
        hyprland_minimal = mkHost {
          hostname = "hyprland_laptop";
          profiles = [ "base" "desktop" "laptop" ];
          homeProfiles = [ "base" "hyprland" ];
        };
        
        # Full desktop configuration
        hyprland_desktop = mkHost {
          hostname = "hyprland_desktop";
          profiles = [ "base" "desktop" "workstation" ];
          homeProfiles = [ "base" "hyprland" "development" ];
        };
        
        # New minimal configuration
        minimal = mkHost {
          hostname = "minimal";
          profiles = [ "minimal" ];
          homeProfiles = [ "minimal" ];
        };
        
        # Legacy/default host (for backward compatibility)
        nixos = self.nixosConfigurations.hyprland_minimal;
      };
    };
}
