{ config, lib, pkgs, ... }:

{
  # Basic system configuration that applies to all hosts
  
  # Enable networking
  networking.networkmanager.enable = true;
  
  # Set your time zone
  time.timeZone = "Europe/Paris";
  
  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Configure console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  
  # Enable basic services
  services = {
    # SSH access
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
  
  # System packages needed on all systems
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
  ];
  
  # Default user shell
  users.defaultUserShell = pkgs.bash;
  
  # Enable sudo
  security.sudo.enable = true;
}
