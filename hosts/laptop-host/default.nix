{ config, lib, pkgs, username ? "yourusername", ... }:

{
  imports = [
    # Import generated hardware configuration
    ./hardware-configuration.nix
    
    # Import system profiles
    ../../profiles/system/laptop.nix
    ../../profiles/system/desktop-hyprland.nix
  ];
  
  # Define hostname and username
  networking.hostName = "nixos-laptop";
  user.name = username;
  user.description = "NixOS User";
  
  # Configure hardware
  modules.core = {
    # France-specific settings
    system = {
      time.timeZone = "Europe/Paris";
      console.keyMap = "fr";
      locale = {
        defaultLocale = "fr_FR.UTF-8";
        extraLocales = [ "en_US.UTF-8" ];
      };
    };

    # Set French keyboard layout
    hardware.peripherals.keyboard = {
      setXkbOptions = true;
      xkbLayout = "fr";
      xkbVariant = "";
      xkbOptions = "eurosign:e";
    };
    
    hardware = {
      # CPU - uncomment based on your hardware
      cpu = {
        intel.enable = true;
        # amd.enable = true;
      };
      
      # GPU - uncomment based on your hardware
      gpu = {
        intel.enable = true;
        # amd.enable = true;
        # nvidia.enable = true;
      };
    };
  };
  
  # Configure display settings
  modules.hyprland = {
    extraConfig = ''
      # Monitor configuration
      monitor=eDP-1,1920x1080@60,0x0,1
      
      # Laptop-specific key bindings
      bind=,XF86MonBrightnessUp,exec,brightnessctl set +5%
      bind=,XF86MonBrightnessDown,exec,brightnessctl set 5%-
      bind=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +5%
      bind=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -5%
      bind=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle
      
      # General key bindings
      bind=SUPER,Return,exec,kitty
      bind=SUPER,Space,exec,wofi --show drun
      bind=SUPERSHIFT,Q,killactive,
      
      # Window management
      bind=SUPER,left,movefocus,l
      bind=SUPER,right,movefocus,r
      bind=SUPER,up,movefocus,u
      bind=SUPER,down,movefocus,d
    '';
  };
  
  # Power management settings
  modules.core.system.power.tlp.settings = {
    # Battery charge thresholds (adjust based on your laptop)
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 90;
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
  };
  
  # Configure home-manager for the user
  home-manager.users.${username} = { ... }: {
    imports = [
      # Import user profiles
      ../../profiles/user/desktop.nix
      ../../profiles/user/development.nix
    ];
    
    # User-specific home configuration
    home = {
      stateVersion = "23.11";
      username = username;
      homeDirectory = "/home/${username}";
    };
    
    # Customize shell settings
    modules.shell = {
      defaultShell = "fish";
      fish.enable = true;
      
      # Customize terminal appearance
      terminal = {
        opacity = 0.9;
      };
      
      # Customize starship prompt
      starship = {
        preset = "tokyo-night";
        settings = {
          add_newline = true;
          command_timeout = 1000;
        };
      };
    };
    
    # Theme customization
    theme.colors = {
      primary = "#7aa2f7";
      background = "#1a1b26";
      foreground = "#c0caf5";
    };
  };
  
  # System-specific packages
  environment.systemPackages = with pkgs; [
    libinput # for trackpad support
    light # for brightness control
    pamixer # for audio control
  ];
  
  # System WiFi configuration
  networking = {
    networkmanager.enable = true;
    wireless.iwd.enable = true;
    networkmanager.wifi.backend = "iwd";
    
    # Add hosts entries for common French websites if desired
    # hosts = {
    #   "51.91.236.255" = [ "laposte.fr" ];
    # };
  };
  
  # Any other laptop-specific settings
  services = {
    # Enable auto-suspend
    logind.lidSwitch = "suspend";
    thermald.enable = true; # CPU temperature management
    
    # Fix for French timezone in Windows dual boot (if applicable)
    time.hardwareClockInLocalTime = true;
  };
}
