{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hyprland;
  
  # Define modifier key for shortcuts
  mod = "SUPER"; # Windows key
  
  # Define common applications
  terminal = cfg.terminal;
  browser = "firefox";
  fileManager = "nautilus";
  launcher = "wofi --show drun";
  screenshot = "grim -g \"$(slurp)\" - | wl-copy";
in
{
  config = lib.mkIf cfg.enable {
    # Add our shortcut configuration to the main Hyprland configuration
    home-manager.users.antonio = {
      wayland.windowManager.hyprland.extraConfig = ''
        # Keyboard shortcuts

        # Application shortcuts
        bind = ${mod}, Return, exec, ${terminal}
        bind = ${mod}, B, exec, ${browser}
        bind = ${mod}, E, exec, ${fileManager}
        bind = ${mod}, R, exec, ${launcher}
        bind = ${mod} SHIFT, S, exec, ${screenshot}

        # Window management
        bind = ${mod}, Q, killactive,
        bind = ${mod} SHIFT, Q, exit,
        bind = ${mod}, F, togglefloating,
        bind = ${mod}, M, fullscreen, 1
        bind = ${mod} SHIFT, M, fullscreen, 0
        
        # Focus
        bind = ${mod}, left, movefocus, l
        bind = ${mod}, right, movefocus, r
        bind = ${mod}, up, movefocus, u
        bind = ${mod}, down, movefocus, d
        
        # Move
        bind = ${mod} SHIFT, left, movewindow, l
        bind = ${mod} SHIFT, right, movewindow, r
        bind = ${mod} SHIFT, up, movewindow, u
        bind = ${mod} SHIFT, down, movewindow, d
        
        # Workspaces
        bind = ${mod}, 1, workspace, 1
        bind = ${mod}, 2, workspace, 2
        bind = ${mod}, 3, workspace, 3
        bind = ${mod}, 4, workspace, 4
        bind = ${mod}, 5, workspace, 5
        bind = ${mod}, 6, workspace, 6
        bind = ${mod}, 7, workspace, 7
        bind = ${mod}, 8, workspace, 8
        bind = ${mod}, 9, workspace, 9
        
        # Move active window to workspace
        bind = ${mod} SHIFT, 1, movetoworkspace, 1
        bind = ${mod} SHIFT, 2, movetoworkspace, 2
        bind = ${mod} SHIFT, 3, movetoworkspace, 3
        bind = ${mod} SHIFT, 4, movetoworkspace, 4
        bind = ${mod} SHIFT, 5, movetoworkspace, 5
        bind = ${mod} SHIFT, 6, movetoworkspace, 6
        bind = ${mod} SHIFT, 7, movetoworkspace, 7
        bind = ${mod} SHIFT, 8, movetoworkspace, 8
        bind = ${mod} SHIFT, 9, movetoworkspace, 9
        
        # Scroll through workspaces
        bind = ${mod}, mouse_down, workspace, e+1
        bind = ${mod}, mouse_up, workspace, e-1
        
        # Volume controls
        bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
        bind = , XF86AudioLowerVolume, exec, pamixer -d 5
        bind = , XF86AudioMute, exec, pamixer -t
        
        # Brightness controls
        bind = , XF86MonBrightnessUp, exec, light -A 5
        bind = , XF86MonBrightnessDown, exec, light -U 5
        
        ${cfg.extraConfig}
      '';
    };
  };
}
