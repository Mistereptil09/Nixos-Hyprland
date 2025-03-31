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
        specialArgs = { 
          inherit inputs; 
          # Pass current hostname to the configuration
          currentHostname = hostname;
        };
        modules = [
          # Import your common configuration first
          ./hosts/common
          
          # Then import host-specific configuration
          ./hosts/${hostname}
          
          # Add home-manager module
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          
          # Add hyprland module
          hyprland.nixosModules.default
        ];
      };
    in
    {
      nixosConfigurations = {
        # Define your specific hosts
        hyprland_minimal = mkHost "laptop";
        
        # This one matches your current hostname for `nixos-rebuild switch` without arguments
        # Replace "nixos" with your actual hostname from `hostname` command if different
        nixos = mkHost "laptop";  
        
        # Create an alias for 'laptop' to directly match the directory name
        laptop = mkHost "laptop";
        
        # Add more hosts as needed
        # desktop = mkHost "desktop";
        # server = mkHost "server";
      };
    };
}
