{ config, lib, pkgs, ... }:

{
  # Import common modules
  imports = [
    ../../../modules/core
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
    ];
  };
}
