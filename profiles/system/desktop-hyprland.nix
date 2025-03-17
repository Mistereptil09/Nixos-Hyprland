{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  config = {
    # Enable graphical support
    services.xserver.enable = true;
    
    # Create Hyprland module placeholder (would need full implementation)
    modules.hyprland = {
      enable = true;
      extraConfig = lib.mkDefault "";
    };
    
    # Set up XDG portal for Wayland
    modules.core.system.xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland
        ];
      };
      mime.enable = true;
    };
    
    # Graphics driver
    modules.core.hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Install important desktop packages
    environment.systemPackages = with pkgs; [
      wayland wl-clipboard
      libnotify
      xdg-utils
      grim slurp   # Screenshots
      swaylock     # Screen locking
      brightnessctl # Brightness control for laptops
    ];
    
    # Fonts for desktop usage
    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = ["JetBrainsMono" "FiraCode"]; })
        noto-fonts
        noto-fonts-cjk 
        noto-fonts-emoji
        liberation_ttf
        roboto
        fira
      ];
    };
    
    # Sound configuration
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
