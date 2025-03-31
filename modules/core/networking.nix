{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.networking;
in {
  options.modules.core.networking = {
    enable = lib.mkEnableOption "Enable networking configuration";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowPing = true;
      };
    };
    
    # Enable mDNS
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
