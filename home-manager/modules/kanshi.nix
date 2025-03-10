{ config, lib, pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    profiles = {
      # Laptop only profile
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";  # Internal laptop display (common name, may need adjustment)
            status = "enable";
            scale = 1.0;
            mode = "1920x1080@60Hz";  # Use your actual native resolution and refresh rate
            adaptive_sync = true;  # Enable if your display supports it
          }
        ];
        exec = [
          # Commands to run when this profile is activated
          "hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1"
        ];
      };
      
      # Laptop + single external monitor via HDMI
      docked-hdmi = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "HDMI-A-*";  # Wildcard to match any HDMI port
            status = "enable";
            position = "1920,0";  # To the right of the laptop screen
            mode = "1920x1080@60Hz";  # Adjust to your external monitor's capabilities
            transform = "normal";
          }
        ];
        exec = [
          "hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1",
          "hyprctl keyword monitor HDMI-A-1,1920x1080@60,1920x0,1"
        ];
      };
      
      # Laptop + single external monitor via DisplayPort/USB-C
      docked-dp = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "DP-*";  # Wildcard to match any DisplayPort connection
            status = "enable";
            position = "1920,0";
            mode = "preferred";  # Use the monitor's preferred mode
          }
        ];
        exec = [
          "hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1",
          "hyprctl keyword monitor DP-1,preferred,1920x0,1"
        ];
      };
      
      # External monitor only (laptop closed)
      external-only = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";  # Turn off laptop display
          }
          {
            criteria = "HDMI-A-* DP-*";  # Match either HDMI or DP
            status = "enable";
            position = "0,0";
            scale = 1.0;
            mode = "preferred";  # Use the monitor's preferred mode
          }
        ];
        exec = [
          "hyprctl keyword monitor eDP-1,disable",
          "hyprctl keyword monitor ,preferred,0x0,1"  # The monitor that's connected
        ];
      };
    };
  };
}
