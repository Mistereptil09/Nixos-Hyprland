{ config, lib, pkgs, ... }:

{
  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    };
  };
  
  # Power profiles daemon alternative
  # services.power-profiles-daemon.enable = true;
  
  # Backlight control
  programs.light.enable = true;
  
  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];
  
  # Enable fingerprint reader if present
  services.fprintd.enable = lib.mkDefault false;
}
