{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hyprland;
in {
  # Import hyprland module from flake
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    # System-level configuration
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    
    environment.systemPackages = with pkgs; [
      hyprpaper
      wl-clipboard
      kitty
    ];
    
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };
}
