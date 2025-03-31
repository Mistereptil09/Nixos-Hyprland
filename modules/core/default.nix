{ config, lib, pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
  ];
}
