{ config, lib, pkgs, currentUsername ? "antonio", ... }:

let
  cfg = config.modules.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # Base Hyprland configuration for home-manager
    home-manager.users.${currentUsername} = {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        
        settings = {
          # Display configuration
          monitor = ",preferred,auto,1";
          
          # General settings
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee)";
            "col.inactive_border" = "rgba(595959aa)";
            layout = "dwindle";
          };
          
          # Decoration settings
          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
            };
            drop_shadow = true;
            shadow_range = 4;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1a1a1aee)";
          };
          
          # Animation settings
          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };
          
          # Input configuration
          input = {
            kb_layout = "us";
            follow_mouse = 1;
            sensitivity = 0;
            touchpad = {
              natural_scroll = true;
            };
          };
          
          # Gestures
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
          };
          
          # Window rules
          windowrule = [
            "float, ^(pavucontrol)$"
            "float, ^(nm-connection-editor)$"
            "float, ^(galculator)$"
          ];
          
          # Startup applications
          exec-once = [
            "waybar"
            "dunst"
            "swww init"
          ];
        };
      };
    };
  };
}
