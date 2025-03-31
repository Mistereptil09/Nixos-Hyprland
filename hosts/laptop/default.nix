{ config, pkgs, inputs, lib, currentHostname ? "laptop", ... }:

let
  hardwareFile = ./hardware-configuration.nix;
  hardwareExists = builtins.pathExists hardwareFile;
in
{
  imports = [
    # Only import hardware-configuration if it exists
    ../common/system
  ] ++ lib.optional hardwareExists hardwareFile;

  # Fail with a clear error message if hardware-configuration.nix doesn't exist
  assertions = [{
    assertion = hardwareExists;
    message = ''
      ERROR: No hardware-configuration.nix found for the ${currentHostname} host.
      
      Please create this file at:
      ${toString hardwareFile}
      
      You can generate it by booting from NixOS installation media and running:
      $ sudo nixos-generate-config --root /mnt
      
      Then copy the generated hardware-configuration.nix to the location above.
    '';
  }];

  # Host-specific configuration
  networking.hostName = "laptop";
  
  # Laptop-specific hardware settings
  services.tlp.enable = true;  # Power management
}

