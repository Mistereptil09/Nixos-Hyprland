{ config, lib, pkgs, ... }:

{
  # Enable core modules
  modules.core = {
    enable = true;
    
    # Specific core module settings
    system.enable = true;
    users = {
      enable = true;
      primaryUser = {
        name = config.user.name;
        description = "Primary User";
        initialPassword = "changeme";
        extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
      };
    };
    hardware.enable = true;
    boot.enable = true;
    networking.enable = true;
    nix.enable = true;
    security = {
      enable = true;
      sudo.enable = true;
    };
  };
  
  # Enable shell environment
  modules.shell = {
    enable = true;
    starship.enable = true;
    git.enable = true;
    tmux.enable = true;
  };
}
