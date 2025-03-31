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
      
      # Function to check if host configuration files exist
      # Returns a clear error message if hardware-configuration.nix is missing
      checkHostConfig = hostname: 
        let
          hostPath = ./hosts + "/${hostname}";
          hardwarePath = hostPath + "/hardware-configuration.nix";
          hostExists = builtins.pathExists hostPath;
          hardwareExists = builtins.pathExists hardwarePath;
        in
        if !hostExists then
          throw "Host '${hostname}' does not exist in ./hosts directory"
        else if !hardwareExists then
          throw ''
            ERROR: No hardware-configuration.nix found for the ${hostname} host.
            
            Please create this file at:
            ${toString hardwarePath}
            
            You can generate it by booting from NixOS installation media and running:
            $ sudo nixos-generate-config --root /mnt
            
            Then copy the generated hardware-configuration.nix to the location above.
          ''
        else true;
      
      # Function to create a host configuration
      mkHost = hostname: 
        # First check if the required files exist
        let _ = checkHostConfig hostname; in 
        # Then create the nixosSystem
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { 
            inherit inputs; 
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
        nixos = mkHost "laptop";
        laptop = mkHost "laptop";
        
        # Add more hosts as needed
        # desktop = mkHost "desktop";
        # server = mkHost "server";
      };
    };
}
