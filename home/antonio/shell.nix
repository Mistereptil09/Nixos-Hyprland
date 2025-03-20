{ config, lib, pkgs, ... }:

{
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        update = "sudo nixos-rebuild switch --flake ~/Nixos-Hyprland#NixFox";
        update-test = "sudo nixos-rebuild test --flake ~/Nixos-Hyprland#NixFox";
      };
      
      # Add custom bashrc content
      initExtra = ''
        # Custom prompt
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        
        # Useful functions
        nix-shell-update() {
          nix-channel --update
          nix-env -u
        }
      '';
    };
    
    # Optional: Add zsh or fish configuration if you prefer
  };
}
