{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.boot;
in {
  options.modules.core.boot = {
    enable = lib.mkEnableOption "Enable boot configuration";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = lib.mkDefault true;
      };
      
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      
      # Default kernel parameters
      kernelParams = [ "quiet" ];
    };
  };
}
