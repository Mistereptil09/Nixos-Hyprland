{ config, lib, pkgs, ... }:

{
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  
  # Gaming optimizations
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;  # For games using a lot of memory maps
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    steam               # Valve's gaming platform
    heroic              # GOG and Epic Games launcher
    gamemode            # Game performance optimizations
    
    # Performance tools
    goverlay            # Vulkan/OpenGL overlay manager
    
    # Emulators
    # retroarch           # Unified emulator frontend
    # dolphin-emu         # GameCube/Wii emulator
    # pcsx2               # PlayStation 2 emulator
    
    # Gamepad support
    xboxdrv             # Advanced Xbox controller driver
  ];

  # Enable GameMode
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
  
  # Controllers
  hardware.xpadneo.enable = true;  # Enhanced Xbox controller driver
  hardware.steam-hardware.enable = true;  # Steam controller support
}