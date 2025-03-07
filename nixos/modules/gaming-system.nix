{ config, lib, pkgs, ... }:

{
  # System-level gaming configurations
  
  # Steam system integration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  
  # Gaming optimizations for kernel
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;  # For games using a lot of memory maps
  };

  # Enable GameMode system service
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };
  
  # Enable 32-bit support for Steam and other gaming applications
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = config.hardware.pulseaudio.enable;
  
  # Controllers support
  hardware.xpadneo.enable = true;  # Enhanced Xbox controller driver
  hardware.steam-hardware.enable = true;  # Steam controller support
  
  # System packages needed for gaming
  environment.systemPackages = with pkgs; [
    gamemode            # Game performance optimizations (system component)
  ];
}
