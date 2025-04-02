{ config, lib, ... }:

with lib;

{
  options.user = {
    name = mkOption {
      type = types.str;
      default = "nixos";
      description = "The primary user's name";
    };
    
    isNormalUser = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the primary user is a normal user";
    };
    
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ "wheel" "networkmanager" ];
      description = "The primary user's additional groups";
    };
    
    initialPassword = mkOption {
      type = types.str;
      default = "nixos";
      description = "The primary user's initial password";
    };
  };

  config = {
    users.users.${config.user.name} = {
      isNormalUser = config.user.isNormalUser;
      extraGroups = config.user.extraGroups;
      initialPassword = config.user.initialPassword;
    };
  };
}