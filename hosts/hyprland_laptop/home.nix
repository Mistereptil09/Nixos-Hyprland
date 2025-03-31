{ config, lib, pkgs, profiles, username, ... }:

{
  # Import base home profile
  imports = with profiles; [
    base
    hyprland
  ];
  
  # Required for home-manager - use the passed username
  home.username = username;
  home.homeDirectory = "/home/${username}";
  
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
