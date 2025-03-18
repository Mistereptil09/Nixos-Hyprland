{
  description = "NixOS + Hyprland Configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland window manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Additional dependencies
    nix-colors.url = "github:misterio77/nix-colors"; # Color schemes
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, nix-colors, nixvim, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      
      # Define default username once here
      defaultUser = "antonio";
      
      # System types to support
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Helper function to generate system configs
      forAllSystems = lib.genAttrs supportedSystems;
      
      # Function to create a NixOS system configuration
      mkHost = { 
        system ? "x86_64-linux",
        hostname, 
        username ? defaultUser,
        modules ? []
      }: lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs hostname username; 
          host = hostname; # For backwards compatibility
        };
        
        modules = [
          # Configure NIX_PATH and other low-level nix settings 
          {
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.nixpkgs.flake = nixpkgs;
          }
          
          # Enable home-manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Fix: Use the specialArgs from parent scope
              extraSpecialArgs = { 
                inherit inputs hostname username; 
                host = hostname;
              };
              
              # Set a default user - can be overridden in host configs
              users.${username} = {
                home.stateVersion = "23.11"; # Use appropriate version 
              };
            };
          }
          
          # Import common modules
          ./common/modules/theme.nix
          
          # Import common host configuration
          ./hosts/common/default.nix
          
          # Include host-specific modules
        ] ++ modules;
      };
    in {
      nixosConfigurations = {
        hyprland_laptop = mkHost {
          hostname = "NixFox"; # changed from hyprland-laptop 
          # No need to specify username, will use defaultUser
          modules = [
            ./hosts/hyprland_laptop/default.nix
          ];
        };
        
        hyprland_desktop = mkHost {
          hostname = "hyprland-desktop"; # changed from hyprland-desktop
          # No need to specify username, will use defaultUser
          modules = [
            ./hosts/hyprland_desktop/default.nix
          ];
        };
        
        laptop-host = mkHost {  # Adding the laptop-host configuration
          hostname = "nixos-laptop";
          # Uses defaultUser="antonio"  
          modules = [
            ./hosts/laptop-host/default.nix
          ];
        };
        
        # Example of overriding the default username for a specific host
        custom_host = mkHost {
          hostname = "custom-host";
          username = "different-user";
          modules = [
            ./hosts/custom_host/default.nix
          ];
        };
      };
      
      # Optional: Development shells or additional outputs
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixpkgs-fmt
            ];
          };
        }
      );
    };
}
