{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  config = {
    # Hyprland user configuration placeholder (would need full implementation)
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        decoration = {
          rounding = 8;
        };
        animations = {
          enabled = true;
        };
      };
    };
    
    # Terminal emulator
    programs.kitty = {
      enable = true;
      theme = "Tokyo Night";
      settings = {
        background_opacity = toString config.modules.shell.terminal.opacity;
        font_family = config.theme.fonts.monospace;
        font_size = config.theme.fonts.sizes.normal;
        enable_audio_bell = false;
        window_padding_width = 4;
      };
    };
    
    # Application launcher
    programs.wofi = {
      enable = true;
      settings = {
        show = "drun";
        width = 500;
        height = 400;
        prompt = "Search Applications";
        normal_window = false;
      };
      style = ''
        * {
          font-family: ${config.theme.fonts.sans};
          color: ${config.theme.colors.foreground};
        }
        window {
          background-color: ${config.theme.colors.background};
          border-radius: 8px;
          border: 2px solid ${config.theme.colors.primary};
        }
      '';
    };
    
    # Desktop user packages
    home.packages = with pkgs; [
      firefox         # Web browser
      thunderbird     # Email
      vlc             # Media player
      gimp            # Image editing
      libreoffice     # Office suite
      evince          # PDF viewer
      gnome.nautilus  # File manager
      gnome.eog       # Image viewer
      discord         # Communication
      keepassxc       # Password manager
    ];
    
    # GTK and icon theme settings
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.adwaita-icon-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
