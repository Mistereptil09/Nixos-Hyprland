{ config, lib, pkgs, username, ... }:

{
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix  # Generated by nixos-generate-config
  ];
  
  # Basic system configuration
  networking.hostName = "hyprland-laptop";
  user.name = username or "your-username";
  
  # Override specific settings for this host
  modules = {
    core = {
      system.time.timeZone = "France/Paris"; # Set your timezone
      hardware = {
        enable = true;
        cpu.intel.enable = true;
        gpu.intel.enable = true;
        audio.enable = true;
        bluetooth.enable = true;
        opengl.enable = true;
        peripherals.touchpad.enable = false;
      };
    };
    
    modules.shell = {
      defaultShell = "fish";
      
      terminal = {
        default = "kitty";
        opacity = 0.9;
      };
      
      zsh.enable = true;
      tmux.enable = true;
      
      utilities = {
        enable = true;
        fzf.enable = true;
        direnv.enable = true;
      };
      
      starship = {
        enable = true;
        preset = "tokyo-night";
      };
    };
  };
}
