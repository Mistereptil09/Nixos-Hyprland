{ config, lib, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    
    # Default kernel parameters
    kernelParams = [ "quiet" ];
  };
}
