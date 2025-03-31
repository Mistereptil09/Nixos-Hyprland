{ config, pkgs, inputs, lib, ... }:

let
  hardwareFile = ./hardware-configuration.nix;
  hardwareExists = builtins.pathExists hardwareFile;
in
{
  imports = [
    # Other modules
    ../../modules/system 
  ] ++ lib.optional hardwareExists hardwareFile;

  # Check for hardware configuration file and throw helpful error if missing
  assertions = [{
    assertion = hardwareExists;
    message = ''
      ERROR: No hardware-configuration.nix found for the laptop host.
      
      Please create this file by either:
      
      1. Boot from a NixOS installation media and run:
         $ sudo nixos-generate-config --root /mnt
         Then copy the generated hardware-configuration.nix to:
         ${toString ./hardware-configuration.nix}
         
      2. Or manually create a basic hardware configuration file at:
         ${toString ./hardware-configuration.nix}
    '';
  }];

  # Host-specific configuration
  networking.hostName = "laptop";
  
  # Laptop-specific hardware settings
  services.tlp.enable = true;  # Power management
  
  # Basic hardware fallbacks - these will be used only if the assertion is removed
  # and no hardware-configuration.nix exists
  boot.loader = lib.mkDefault {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
