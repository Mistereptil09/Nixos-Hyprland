{
  description = "NixOS Hyprland Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # Make Hyprland use the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Optional: add more inputs as needed
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Function to create home-manager configs
      mkHome = { username, system ? "x86_64-linux" }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { 
          inherit inputs;
          inherit username; 
        };
        home-manager.users.${username} = import ./home-manager/home.nix;
      };
    in 
    {
      nixosConfigurations = {
        # Default configuration - will be replaced with user's hostname
        hyprland = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            (mkHome { username = "YOUR_USERNAME"; })
          ];
        };
      };
      
      # Standalone home-manager configuration
      homeConfigurations = {
        "YOUR_USERNAME" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/home.nix
          ];
        };
      };
      
      # Development shells for maintaining this flake
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            git
            nixpkgs-fmt
            nil # Nix language server
          ];
        };
      });
    };
}
