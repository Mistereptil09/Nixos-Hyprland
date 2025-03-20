{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./shell.nix
  ];

  # Home-Manager configuration
  home = {
    username = "antonio";
    homeDirectory = "/home/antonio";
    
    # Basic packages for the user
    packages = with pkgs; [
      firefox
      thunderbird
      vscode
      spotify
      discord
      libreoffice
      gimp
    ];
    
    # User-specific files
    file = {
      # Example configurations
      ".config/wallpapers".source = ./wallpapers;
    };
  };
  
  # Enable program-specific configurations
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        update = "sudo nixos-rebuild switch";
      };
    };
    
    git = {
      enable = true;
      userName = "Antonio";
      userEmail = "your-email@example.com";
    };
    
    # Configure various applications
    alacritty.enable = true;
    rofi.enable = true;
  };
  
  # Set stateVersion for home-manager
  home.stateVersion = "23.11";
}
