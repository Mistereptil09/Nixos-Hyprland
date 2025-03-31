{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hyprland;
in {
  # Import hyprland module from flake
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    # Enable hyprland
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };
    
    # Enable XDG portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
    
    # System packages needed for Hyprland
    environment.systemPackages = with pkgs; [
      waybar
      dunst
      libnotify
      swww
      wl-clipboard
      grim
      slurp
      wofi
      libsForQt5.polkit-kde-agent
    ];
    
    # Enable sound
    sound.enable = true;
    hardware.pulseaudio.enable = lib.mkDefault true;
    
    # Enable Bluetooth
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    
    # Enable fonts
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      font-awesome
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
  };
}
