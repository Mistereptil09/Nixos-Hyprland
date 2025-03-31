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

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      
      # Import helper functions
      helpers = import ./common/lib/helpers.nix { inherit lib; };
      
      # Import profiles and hosts from dedicated files
      profiles = import ./profiles.nix { inherit lib helpers; };
      hosts = import ./hosts.nix { 
        inherit self lib system nixpkgs home-manager; 
        # Forward inputs to hosts.nix
        inputs = inputs;
      };
    in
    {
      # Make profiles available in the flake
      nixosProfiles = profiles.nixosProfiles;
      homeProfiles = profiles.homeProfiles;
      
      # Host configurations
      nixosConfigurations = {
        minimal = nixpkgs.lib.nixosSystem {
          # Adjust the system as needed for your hardware
          system = "x86_64-linux"; 
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/minimal
          ];
        };
        nixos = hosts.hosts.minimal;
      };
    };
}
