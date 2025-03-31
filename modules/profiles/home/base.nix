{ config, lib, pkgs, ... }:

{
  imports = [
    ../../shell/zsh/config.nix
    ../../shell/git/config.nix
  ];
  
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
        exa
        fzf
      ];
    };
    
    # Standard programs configuration 
    programs = {
      home-manager.enable = true;
      alacritty = {
        enable = true;
        settings = {
          window.opacity = 0.95;
          font.size = 11;
        };
      };
    };
  };
}
