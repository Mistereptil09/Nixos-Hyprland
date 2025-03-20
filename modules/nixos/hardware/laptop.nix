{ config, lib, pkgs, ... }:

{
  # Laptop-specific hardware settings
  hardware = {
    acpilight.enable = true;
    
    # Power management
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
    };
  };
  
  # Services for laptops
  services = {
    # Power management
    tlp.enable = true;
    thermald.enable = true;
    
    # Touchpad support
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };
  };
  
  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
    powertop
  ];
}
