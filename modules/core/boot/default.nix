{ lib, pkgs, config, ... }:

with lib;

{
  options.core.boot = {
    enable = mkEnableOption "Enable core boot configuration";
  };

  config = mkIf config.core.boot.enable {
    # Boot loader configuration
    boot.loader = {
      grub.devices = [ "/vda/vda1" ]; # Replace with your boot disk
      systemd-boot = {
        enable = true;
      };
      # efi = {
      #   canTouchEfiVariables = true;
      #   efiSysMountPoint = "/boot";  # Make sure this matches your boot partition
      # };
      # Explicitly disable GRUB to avoid conflicts
      grub.enable = true;
      
    };
    
    # Add other boot-related settings
  };
}
