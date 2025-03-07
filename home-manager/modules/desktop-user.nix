{ config, lib, pkgs, inputs ? {}, ... }:

{
  # User-level Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    # Use Hyprland from flake inputs if available
    package = lib.mkIf (inputs ? hyprland) inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # Define user environment variables
    systemd.variables = [
      "NIXOS_OZONE_WL=1"
      "MOZ_ENABLE_WAYLAND=1"
      "QT_QPA_PLATFORM=wayland"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
      "SDL_VIDEODRIVER=wayland"
      "_JAVA_AWT_WM_NONREPARENTING=1"
    ];
    
    # Custom Hyprland config
    extraConfig = ''
      # Monitor configuration
      monitor=,preferred,auto,auto
      
      # Set variables
      $terminal = kitty
      $menu = wofi --show drun
      $browser = firefox
      $fileManager = thunar
      
      # Autostart applications
      exec-once = waybar
      exec-once = swww init
      exec-once = mako
      exec-once = nm-applet

      # Input configuration
      input {
          kb_layout = fr  # Match the system layout
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =
        
          follow_mouse = 1
          touchpad {
              natural_scroll = true
          }
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }
      
      # Key bindings
      bind = SUPER, Return, exec, $terminal
      bind = SUPER, Q, killactive, 
      bind = SUPER, M, exit, 
      bind = SUPER, E, exec, $fileManager
      bind = SUPER, V, togglefloating, 
      bind = SUPER, D, exec, $menu
      bind = SUPER, P, pseudo, # dwindle
      bind = SUPER, F, fullscreen,
      bind = SUPER, B, exec, $browser
      
      # Screenshot
      bind = SUPER, S, exec, grimblast copy area
      
      # Move focus with SUPER + arrow keys
      bind = SUPER, left, movefocus, l
      bind = SUPER, right, movefocus, r
      bind = SUPER, up, movefocus, u
      bind = SUPER, down, movefocus, d
      
      # Workspaces
      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5
      bind = SUPER, 6, workspace, 6
      bind = SUPER, 7, workspace, 7
      bind = SUPER, 8, workspace, 8
      bind = SUPER, 9, workspace, 9
      bind = SUPER, 0, workspace, 10
      
      # Move active window to a workspace
      bind = SUPER SHIFT, 1, movetoworkspace, 1
      bind = SUPER SHIFT, 2, movetoworkspace, 2
      bind = SUPER SHIFT, 3, movetoworkspace, 3
      bind = SUPER SHIFT, 4, movetoworkspace, 4
      bind = SUPER SHIFT, 5, movetoworkspace, 5
      bind = SUPER SHIFT, 6, movetoworkspace, 6
      bind = SUPER SHIFT, 7, movetoworkspace, 7
      bind = SUPER SHIFT, 8, movetoworkspace, 8
      bind = SUPER SHIFT, 9, movetoworkspace, 9
      bind = SUPER SHIFT, 0, movetoworkspace, 10
    '';
  };

  # User-specific desktop utilities (moved from system)
  home.packages = with pkgs; [
    # Desktop environment utilities
    waybar              # Status bar
    swww                # Wallpaper daemon 
    mako                # Notification daemon
    wofi                # Application launcher
    swaybg              # Wallpaper utility
    
    # Wayland utilities
    hyprpicker          # Color picker
    swayidle            # Idle management
    kanshi              # Dynamic display management
    grimblast           # Screenshot utility
    
    # Lock screen
    swaylock-effects    # Screen locker with effects
  ];
  
  # Configure waybar
  programs.waybar = {
    enable = true;
    style = ''
      /* Waybar styles will go here */
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = ["hyprland/workspaces" "hyprland/window"];
        modules-center = ["clock"];
        modules-right = ["network" "cpu" "memory" "pulseaudio" "battery" "tray"];
      };
    };
  };
}
