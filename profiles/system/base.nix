{ config, lib, pkgs, ... }:

{
  # Define base user options
  options.user = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Primary user name";
    };
    
    description = lib.mkOption {
      type = lib.types.str;
      default = "Primary User";
      description = "Primary user description";
    };
  };
  
  config = {
    # Enable core modules
    modules.core = {
      enable = true;
      system = {
        enable = true;
        stateVersion = "23.11";
        time.timeZone = lib.mkDefault "Europe/Paris"; # Changed from UTC to Paris
        fonts.enable = true;
        # Added locale settings for France
        locale = {
          defaultLocale = lib.mkDefault "fr_FR.UTF-8";
          extraLocales = lib.mkDefault [ "en_US.UTF-8" ];
        };
        packages = {
          base = lib.mkDefault (with pkgs; [
            coreutils curl wget git vim htop
            zip unzip pciutils usbutils
          ]);
        };
      };
      
      users = {
        enable = true;
        primaryUser = {
          name = config.user.name;
          description = config.user.description;
          initialPassword = lib.mkDefault "changeme";
          extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
        };
      };
      
      boot = {
        enable = true;
        loader = {
          type = lib.mkDefault "systemd-boot";
          timeout = lib.mkDefault 5;
        };
        tmpOnTmpfs = true;
      };
      
      networking = {
        enable = true;
        useNetworkManager = true;
      };
      
      nix = {
        enable = true;
        gc = {
          enable = true;
          automatic = true;
          dates = "weekly";
        };
        enableFlakes = true;
        allowUnfree = true;
      };
      
      security = {
        enable = true;
        sudo.enable = true;
        firewall.enable = true;
        polkit.enable = true;
      };
    };
    
    # Default shell setup
    modules.shell = {
      enable = true;
      defaultShell = lib.mkDefault "bash";
      env = {
        enable = true;
        variables = {
          EDITOR = "vim";
          VISUAL = "vim";
        };
      };
    };
  };
}
