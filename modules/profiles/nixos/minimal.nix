{ config, lib, pkgs, ... }:

{
  # Enable only essential modules for a minimal installation
  modules = {
    core = {
      # Essential modules like nix, boot, and networking
      # Assuming these modules exist in the system
      nix.enable = true;
      boot.enable = true;
      networking.enable = true;
    };
  };

  # Basic system configuration
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Create a basic user (will be configured via the host)
  users.users.${config.currentUsername} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    htop
  ];

  # Enable SSH for remote management
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Minimal system services
  services = {
    timesyncd.enable = true;
  };

  # Basic locale and time settings
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Use systemd-boot for a minimal bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Minimal firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
