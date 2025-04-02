{ config, lib, pkgs, ... }:

{
  imports = [
    ../../editor/neovim
  ];

  # Enable the Neovim module
  modules.editor.neovim.enable = true;
  
  # Basic system configuration
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # User configuration
  user = {
    name = "nixos";
    initialPassword = "nixos";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Basic packages
  environment.systemPackages = with pkgs; [
    wget
    git
  ];
  
  # Set state version
  system.stateVersion = "23.11";
}