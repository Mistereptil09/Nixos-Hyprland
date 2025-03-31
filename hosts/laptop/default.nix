{ config, pkgs, inputs, lib, currentHostname ? "laptop", ... }:

{
  imports = [
    # Hardware configuration is imported directly
    ./hardware-configuration.nix
    
    # Common system configuration
    ../common/system
  ];

  # Host-specific configuration
  networking.hostName = "laptop";
  
  # Laptop-specific hardware settings
  services.tlp.enable = true;  # Power management
}

