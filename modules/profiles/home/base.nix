{ config, lib, pkgs, ... }:

{
  # Base user configuration
  config = {
    # Common home-manager settings
    home = {
      stateVersion = "23.11";
      
      sessionVariables = {
        EDITOR = "vim";
        TERMINAL = "kitty";
      };
      
      packages = with pkgs; [
        ripgrep
        fd
        bat
        htop
      ];
    };
    
    # Standard programs configuration 
    programs = {
      home-manager.enable = true;
    };
  };
}
