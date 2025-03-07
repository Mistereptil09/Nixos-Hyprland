{ config, lib, pkgs, ... }:

{
  # User-level gaming applications
  home.packages = with pkgs; [
    # Game launchers
    steam               # Valve's gaming platform
    heroic              # GOG and Epic Games launcher
    lutris              # Open gaming platform
    
    # Performance tools
    goverlay            # Vulkan/OpenGL overlay manager
    mangohud            # Vulkan and OpenGL overlay for monitoring performance
    
    # Emulators (uncomment as needed)
    # retroarch         # Unified emulator frontend
    # dolphin-emu       # GameCube/Wii emulator
    # pcsx2             # PlayStation 2 emulator
    # ppsspp            # PSP emulator
    # duckstation        # PlayStation 1 emulator
    
    # Game development tools (optional)
    # godot             # Open source game engine
    # unity-editor      # Unity game development platform
  ];
  
  # Configure gamehub directories 
  xdg.userDirs.enable = true;
  
  # MangoHud configuration (uncomment and customize if needed)
  # home.file.".config/MangoHud/MangoHud.conf".text = ''
  #   fps_limit=144
  #   toggle_hud=F9
  #   gpu_stats
  #   cpu_stats
  #   ram
  #   engine_version
  #   vulkan_driver
  #   frame_timing
  # '';
  
  # Steam configuration with Proton GE (uncomment if needed)
  # home.activation.protonGE = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   if [ ! -d "$HOME/.steam/root/compatibilitytools.d" ]; then
  #     $DRY_RUN_CMD mkdir -p $HOME/.steam/root/compatibilitytools.d
  #   fi
  # '';
}
