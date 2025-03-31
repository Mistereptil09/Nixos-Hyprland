# This is a placeholder file with instructions
{ config, lib, pkgs, modulesPath, ... }:

# Throw an error with clear instructions when this file is evaluated
throw ''
  This is a placeholder hardware-configuration.nix file.
  
  Please replace it with a real hardware configuration by:
  
  1. Boot from a NixOS installation media
  2. Mount your target partitions under /mnt
  3. Run: sudo nixos-generate-config --root /mnt
  4. Copy the generated hardware-configuration.nix to replace this file at:
     /home/developpement/Coding/Perso/Nixos-Hyprland/hosts/laptop/hardware-configuration.nix
     
  After installing, you can delete this comment and use the real configuration.
''
