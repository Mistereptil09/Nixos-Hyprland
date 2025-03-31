{ lib, nixpkgs, home-manager, inputs, ... }:

{
  # Function to import host configuration
  # Call with hostname as argument
  importHost = hostname:
    let
      hostPath = ./. + "/${hostname}";
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
    else {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # Import the host-specific configuration
          ./${hostname}
        ];
      };
    };
}
