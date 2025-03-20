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
      
      # Import all modules
      nixosModules = import ./modules/nixos;
      homeModules = import ./modules/home;
      
      # Function to create a NixOS system configuration
      mkHost = { 
        system ? "x86_64-linux",
        hostname, 
        username ? defaultUser,
        profile ? "desktop", # default profile
        extraModules ? []
      }: lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs hostname username; 
          host = hostname; # For backwards compatibility
        };
        
        modules = [
          # Basic Nix configuration
          {
            nix = {
              nixPath = [ "nixpkgs=${nixpkgs}" ];
              registry.nixpkgs.flake = nixpkgs;
              settings = {
                experimental-features = [ "nix-command" "flakes" ];
                auto-optimise-store = true;
              };
            };
          }
          
          # Import system profile
          ./profiles/${profile}.nix
          
          # Host-specific configuration
          ./hosts/${hostname}
          
          # Home manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { 
                inherit inputs hostname username; 
                host = hostname;
              };
              
              # Import user home-manager configuration
              users.${username} = import ./home/${username};
            };
          }
        ] ++ extraModules;
      };
    in {
      # Export NixOS modules for reuse
      inherit nixosModules;
      inherit homeModules;
      
      # NixOS configurations
      nixosConfigurations = {
        # Laptop with Hyprland
        NixFox = mkHost {
          hostname = "NixFox";
          profile = "desktop";
          extraModules = [
            nixosModules.hyprland
            nixosModules.laptop
          ];
        };
        
        # Desktop with Hyprland
        hyprland-desktop = mkHost {
          hostname = "hyprland-desktop";
          profile = "desktop";
          extraModules = [
            nixosModules.hyprland
            nixosModules.desktop
          ];
        };
        
        # Simple host-laptop configuration
        nixos-laptop = mkHost {
          hostname = "nixos-laptop";
          profile = "minimal";
          extraModules = [
            nixosModules.laptop
          ];
        };
        
        # Example with different user
        custom-host = mkHost {
          hostname = "custom-host";
          username = "different-user";
          profile = "minimal";
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
