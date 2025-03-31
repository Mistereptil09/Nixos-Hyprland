{ config, lib, pkgs, ... }:

# This file should be replaced with one generated by nixos-generate-config
# It will be used for hardware-specific configuration

{
  # Import the generated hardware configuration when available
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix) 
    ./hardware-configuration.nix;
  
  # If no hardware configuration exists, provide an error with instructions
  assertions = [{
    assertion = builtins.pathExists ./hardware-configuration.nix;
    message = ''
      ERROR: No hardware-configuration.nix found for the hyprland_laptop host.
      
      Please generate one by booting from NixOS installation media and running:
      $ sudo nixos-generate-config --root /mnt
      
      Then copy the generated hardware-configuration.nix to:
      ${toString ./hardware-configuration.nix}
    '';
  }];
  
  # Basic hardware fallbacks if assertion is removed
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
}
