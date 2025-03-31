{ config, lib, pkgs, ... }:

{
  # Minimal shell configuration
  programs = {
    # Configure bash with minimal settings
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        update = "sudo nixos-rebuild switch";
      };
      initExtra = ''
        export EDITOR=vim
      '';
    };

    # Basic git configuration
    git = {
      enable = true;
      # User will need to set their own name and email
    };
  };

  # Minimal set of user packages
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    tree
  ];

  # Basic home-manager settings
  home.stateVersion = "23.11"; # Update to match your NixOS version
  
  # Enable home-manager itself
  programs.home-manager.enable = true;
}
