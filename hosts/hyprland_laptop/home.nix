{ config, lib, pkgs, profiles, ... }:

{
  # Import base home profile
  imports = with profiles; [
    base
    hyprland
  ];
  
  # Host-specific home configuration
  wayland.windowManager.hyprland.settings = {
    # Override default Hyprland configuration for this specific host
    input = {
      kb_layout = "us";
      touchpad = {
        natural_scroll = true;
      };
    };
    
    # Host-specific keybindings
    binds = {
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
  
  # Host-specific wallpaper
  home.file.".config/hypr/wallpaper.jpg".source = ../../assets/wallpapers/default.png;
}
