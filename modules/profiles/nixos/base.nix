{ config, lib, pkgs, currentUsername ? "antonio", ... }:

{
  # Import common modules
  imports = [
    ../../core
  ];
  
  # Define the user option
  options.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = currentUsername;
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
    # Enable core module
    modules.core.enable = true;
    
    # Create user
    users.users.${config.user.name} = {
      isNormalUser = true;
      description = config.user.description;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      initialPassword = "changeme";
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
    
    # Sudo settings
    security.sudo.wheelNeedsPassword = false;
  };
}
