{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
in
{
  imports = [
    ./install.nix
    ./config.nix
  ];
}
