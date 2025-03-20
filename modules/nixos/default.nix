{
  # Core modules - fundamentals needed for any system
  core = import ./core;
  
  # Hardware-specific modules
  laptop = import ./hardware/laptop.nix;
  desktop = import ./hardware/desktop.nix;
  
  # Desktop environments
  hyprland = import ./desktop/hyprland.nix;
  
  # Services
  pipewire = import ./services/audio/pipewire.nix;
  printing = import ./services/printing.nix;
  
  # Utilities
  fonts = import ./utilities/fonts.nix;
  theming = import ./utilities/theming.nix;
}
