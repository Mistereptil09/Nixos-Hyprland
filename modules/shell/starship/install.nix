{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.starship;
in {
  config = lib.mkIf cfg.enable {
    # Install starship at system level
    environment.systemPackages = with pkgs; [
      starship
    ];
    
    # Provide required dependencies
    programs.starship = {
      enable = true; # Enable system-wide starship
    };
    
    # Ensure we have a nerd font available for symbols if using nerd-font preset
    fonts.packages = lib.mkIf (cfg.preset == "nerd-font") (with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ]);
  };
}
