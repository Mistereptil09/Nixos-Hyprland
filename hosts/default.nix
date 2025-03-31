{ lib, nixpkgs, home-manager, inputs, ... }:

{
  # Function to import host configuration
  # Call with hostname as argument
  importHost = hostname:
    if builtins.pathExists ./. ++ "/${hostname}"
    then {
      # Return the nixosConfigurations for the given hostname
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # Import the host-specific configuration
          ./${hostname}
        ];
      };
    }
    else throw "Host '${hostname}' does not exist!";
}
