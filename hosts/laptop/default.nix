{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system # Your shared system configuration
    # Other modules you want to include
  ];

  # Host-specific configuration
  networking.hostName = "laptop";
  
  # Laptop-specific hardware settings
  services.tlp.enable = true;  # Power management
  
  # ...existing code...
}
