{ config, lib, pkgs, ... }:

{
  # Common configuration for all hosts
  
  # Basic Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };
  
  # Enable basic system services
  services.xserver.enable = true;
  
  # Default locale settings
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Default packages for all hosts
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
  ];
  
  # Default system configuration
  system.stateVersion = "23.11"; # Change to match your NixOS version
}
