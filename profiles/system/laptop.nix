{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  config = {
    # Laptop-specific core configurations
    modules.core = {
      hardware = {
        enable = true;
        peripherals.touchpad = {
          enable = true;
          naturalScrolling = true;
          tapping = true;
        };
        opengl.enable = true;
        audio.enable = true;
        bluetooth.enable = true;
      };
      
      system.power = {
        enable = true;
        tlp = {
          enable = true;
          settings = {
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
            START_CHARGE_THRESH_BAT0 = 75;
            STOP_CHARGE_THRESH_BAT0 = 80;
          };
        };
      };
    };
    
    # Add laptop-specific packages
    environment.systemPackages = with pkgs; [
      acpi light powertop
      xorg.xbacklight
      iw
    ];
  };
}
