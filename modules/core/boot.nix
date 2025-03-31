{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.boot;
in {
  options.modules.core.boot = {
    enable = lib.mkEnableOption "Enable boot configuration";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
