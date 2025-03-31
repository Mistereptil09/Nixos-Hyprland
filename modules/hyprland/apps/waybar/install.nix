{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      waybar
    ];
  };
}
