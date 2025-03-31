{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/profiles/home/base.nix
  ];
  
  # Host-specific home configuration
  programs.kitty = {
    enable = true;
    settings = {
      font_size = 11;
      background_opacity = "0.95";
    };
  };
}
