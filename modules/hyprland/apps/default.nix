{ config, lib, pkgs, ... }:

{
  imports = [
    ./wofi
    ./waybar
    ./terminal
  ];
}
