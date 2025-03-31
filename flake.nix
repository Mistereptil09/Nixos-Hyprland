{
  description = "Minimal NixOS + Hyprland Configuration";

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
      
      # Function to create a NixOS system configuration
      mkHost = { 
        hostname, 
        username ? "user",
        modules ? [] 
      }: lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs hostname username; 
        };
        
        modules = [
          # Enable home-manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          
          # Import common configuration
          ./hosts/common/default.nix
          
          # Include user-provided modules
        ] ++ modules;
      };
    in {
      nixosConfigurations = {
        # Minimal configuration
        minimal = mkHost {
          hostname = "nixos-minimal";
          username = "user";
          modules = [
            ./hosts/hyprland_minimal/default.nix
          ];
        };
      };
    };
}
