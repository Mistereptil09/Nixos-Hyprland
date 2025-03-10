{ config, lib, pkgs, ... }:

{
  # System-level Hyprland and Wayland integration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Desktop Portal for screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # SDDM display manager with Wayland enabled
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Global keyboard layout
  services.xserver = {
    xkb = {
      layout = "fr";  # Change to your preferred layout
      variant = "";
    };
    # Enable libinput for better touchpad support
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };
  };
  
  console.keyMap = "fr";  # Same as xkb.layout above

  # PipeWire for better audio/video handling
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Hardware acceleration
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      # Vulkan support
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
      ];
    };
    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # NetworkManager for better network connectivity
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  services.thermald.enable = true;  # CPU temperature management
  services.auto-cpufreq.enable = true;  # Automatic CPU frequency scaling

  # Automatic mounting of removable media
  services.udisks2.enable = true;
  services.gvfs.enable = true;  # For trash, MTP and other functionalities

  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["DejaVu Sans Mono" "Noto Sans Mono"];
        serif = ["DejaVu Serif" "Noto Serif"];
        sansSerif = ["DejaVu Sans" "Noto Sans"];
      };
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      dejavu_fonts
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
  };

  # System-wide session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";    
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    
    # Add this if you have an NVIDIA GPU for better compatibility
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Only core system packages needed for Hyprland to function
  environment.systemPackages = with pkgs; [
    libnotify           # Desktop notifications library
    wl-clipboard        # Clipboard utilities for Wayland
    xdg-utils           # Desktop integration utilities 
    xdg-desktop-portal-hyprland # Hyprland portal for screen sharing
    
    # Additional useful utilities
    networkmanagerapplet  # NetworkManager GUI
    pavucontrol          # PulseAudio/PipeWire volume control
    blueman              # Bluetooth manager
    polkit_gnome         # Authentication agent
    brightnessctl        # Brightness control for laptops
    
    # Basic system monitoring
    htop
    btop
    
    # Better hardware info
    lm_sensors           # For temperature monitoring
    pciutils            # For PCI device info
    usbutils            # For USB device info
    
    # Screen management
    kanshi              # Auto display configuration
    wlr-randr           # Screen management utility
    wdisplays           # GUI display configurator for wlroots
  ];

  # Polkit for privilege escalation
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Automatic screen configuration
  services.kanshi = {
    enable = true;
    # systemdTarget = "hyprland-session.target"; # Uncomment if needed for systemd integration
  };

  # Start kanshi with the desktop session
  systemd.user.services.kanshi = {
    description = "Kanshi dynamic display configuration";
    wantedBy = [ "hyprland-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi";
      RestartSec = 5;
      Restart = "always";
    };
  };
}