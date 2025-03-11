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
    
    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      
      # Function to create a NixOS system configuration
      mkHost = { 
        system ? "x86_64-linux",
        hostname, 
        username,
        modules ? [],
        extraSpecialArgs ? {}
      }: lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs hostname username;
        } // extraSpecialArgs;
        
        modules = [
          # Enable home-manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { 
                inherit inputs hostname username; 
              } // extraSpecialArgs;
            };
          }
          
          # Include common modules
          ./common/modules/theme.nix
          
          # Import common host configuration
          ./hosts/common/default.nix
          
          # Include user-provided modules
        ] ++ modules;
      };
      
      # Supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # For each system
      forAllSystems = lib.genAttrs supportedSystems;
      
    in {
      # NixOS configurations
      nixosConfigurations = {
        # Laptop configuration
        laptop = mkHost {
          hostname = "nixos-laptop";
          username = "alice";  # Change this to your username
          modules = [
            ./hosts/laptop/default.nix
          ];
        };
        
        # Desktop configuration
        desktop = mkHost {
          hostname = "nixos-desktop";
          username = "alice";  # Change this to your username
          modules = [
            ./hosts/desktop/default.nix
          ];
        };
      };
      
      # Standalone home configurations (if needed outside NixOS)
      homeConfigurations = {
        "alice@generic" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/profiles/base.nix
            ./home-manager/profiles/desktop.nix
            {
              home = {
                username = "alice";
                homeDirectory = "/home/alice";
                stateVersion = "23.11";
              };
            }
          ];
        };
      };
      
      # Development shell with helpful utilities
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nil # Nix language server
              nixpkgs-fmt # Nix formatter
              nix-output-monitor # Better nix build output
              nix-diff # Compare nix derivations
              
              # For testing
              nixos-generators
            ];
            shellHook = ''
              echo "NixOS + Hyprland Development Shell"
              echo ""
              echo "Available commands:"
              echo "  rebuild-laptop    - Rebuild and switch to laptop configuration"
              echo "  rebuild-desktop   - Rebuild and switch to desktop configuration"
              echo "  build-laptop      - Build laptop configuration without activating"
              echo "  build-desktop     - Build desktop configuration without activating"
              echo "  check-laptop      - Check configuration for errors"
              echo "  check-desktop     - Check configuration for errors"
              echo ""
              
              alias rebuild-laptop="sudo nixos-rebuild switch --flake .#laptop"
              alias rebuild-desktop="sudo nixos-rebuild switch --flake .#desktop"
              alias build-laptop="nix build .#nixosConfigurations.laptop.config.system.build.toplevel"
              alias build-desktop="nix build .#nixosConfigurations.desktop.config.system.build.toplevel"
              alias check-laptop="nix eval .#nixosConfigurations.laptop.config.system.build.toplevel"
              alias check-desktop="nix eval .#nixosConfigurations.desktop.config.system.build.toplevel"
            '';
          };
        }
      );
    };
}