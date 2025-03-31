{ config, lib, pkgs, ... }:

{
  # Import common modules
  imports = [
    ../../../modules/core
    ../../core
  ];
  
  # Define the user option
  options.user = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Primary user name";
    };
    
    description = lib.mkOption {
      type = lib.types.str;
      default = "Primary User";
      description = "Primary user description";
    };
  };
  
  # Base system configuration
  config = {
    # Enable base modules
    modules.core = {
      nix.enable = true;
      boot.enable = true;
      networking.enable = true;
    };
    
    # Create user
    users.users.${config.user.name} = {
      isNormalUser = true;
      description = config.user.description;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    };
    
    # Basic packages that should be available everywhere
    environment.systemPackages = with pkgs; [
      git
      vim
      curl
      wget
      htop
      unzip
      file
    ];
    
    # Time and locale settings
    time.timeZone = lib.mkDefault "UTC";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    
    # Default user
    users.users.antonio = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      initialPassword = "changeme";
    };
    
    # Sudo settings
    security.sudo.wheelNeedsPassword = false;
  };
}
