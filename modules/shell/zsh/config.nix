{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "sudo" ];
      theme = "robbyrussell";
    };
    
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake ~/Nixos-Hyprland#";
      code = "code --enable-features=UseOzonePlatform --ozone-platform=wayland";
    };
  };
}
