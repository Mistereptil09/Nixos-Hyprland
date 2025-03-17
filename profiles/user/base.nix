{ config, lib, pkgs, ... }:

{
  config = {
    # Shell configuration
    modules.shell = {
      git = {
        enable = true;
      };
      tmux = {
        enable = true;
        historyLimit = 10000;
        keyMode = "vi";
      };
      starship = {
        enable = true;
        preset = "nerd-font";
      };
      
      # Terminal utilities
      utilities = {
        enable = true;
        modern-unix = true;
        fzf.enable = true;
        zoxide.enable = true;
        direnv = {
          enable = true;
          nix-direnv = true;
          flakesSupport = true;
        };
      };
      
      # Terminal emulator
      terminal = {
        default = "kitty";
        opacity = 0.95;
        scrollback = 10000;
      };
      
      # Environment variables
      env = {
        enable = true;
        variables = {
          EDITOR = "vim";
          VISUAL = "vim";
          PAGER = "less";
        };
        shellAliases = {
          ls = "eza";
          ll = "eza -la";
          g = "git";
          vim = "nvim";
        };
      };
    };
    
    # User packages
    home.packages = with pkgs; [
      ripgrep fd bat htop
      jq curl wget
      neofetch
    ];
    
    # Basic programs configuration
    programs = {
      home-manager.enable = true;
    };
  };
}
