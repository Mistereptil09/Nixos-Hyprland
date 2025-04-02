{ lib, pkgs, config, ... }:

with lib;

{
  options.core.boot = {
    enable = mkEnableOption "Enable core boot configuration";
  };

  config = mkIf config.core.boot.enable {
    # Boot loader configuration
    boot.loader = {
      grub = {
        enable = true;
        device = "nodev";       # Use "nodev" when targeting a specific disk
        devices = [ "/dev/vda" ]; # For VMs, install to the whole disk
      };
    };
  };
}