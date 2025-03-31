# This is an error-throwing hardware configuration placeholder
{ config, lib, pkgs, modulesPath, ... }:

throw ''
  ERROR: You need to create a proper hardware configuration!
  
  Please generate a hardware configuration by:
  
  1. Boot from a NixOS installation media
  2. Mount your target partitions under /mnt
  3. Run: sudo nixos-generate-config --root /mnt
  4. Copy the generated hardware-configuration.nix to replace this file at:
     /home/developpement/Coding/Perso/Nixos-Hyprland/hardware-configuration.nix
  
  After replacing this file, you can proceed with building your configuration.
''
