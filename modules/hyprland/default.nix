{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];
  
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland window manager";
    
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };
    
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Hyprland configuration";
    };
  };
}
