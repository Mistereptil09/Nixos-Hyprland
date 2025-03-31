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
      
      # Function to create a host configuration
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          
          # Host-specific configuration
          ./hosts/${hostname}
        ];
      };
    in
    {
      nixosConfigurations = {
        # Define your hosts here
        hyprland_minimal = mkHost "laptop";
        # Add more hosts as needed
        # desktop = mkHost "desktop";
        # server = mkHost "server";
        
        # Backwards compatibility for the old approach
        default = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            ./hosts/common/default.nix
          ];
        };
      };
    };
}
