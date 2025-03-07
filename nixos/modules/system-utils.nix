{ config, lib, pkgs, ... }:

{
  # System-level utility packages and configuration
  environment.systemPackages = with pkgs; [
    # Core system utilities
    libnotify           # Desktop notifications library (system component)
    xdg-utils           # Desktop integration utilities
    
    # Audio and hardware controls
    pamixer             # PulseAudio mixer CLI
    brightnessctl       # Brightness control for displays
    
    # System management
    networkmanagerapplet # Network manager applet
    pavucontrol         # PulseAudio volume control GUI
    blueman             # Bluetooth manager
    
    # System monitoring
    htop                # Interactive process viewer
    duf                 # Disk usage utility with better UI
  ];
  
  # Sound related configuration
  sound.mediaKeys.enable = true;
  
  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  # Enable NetworkManager
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # Disable wifi powersaving for better performance
  };
}
