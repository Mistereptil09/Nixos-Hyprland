{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.system;
in {
  options.modules.core.system = {
    enable = lib.mkEnableOption "Enable system configuration";
    
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "23.11";
      description = "NixOS state version";
    };
    
    time = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "UTC";
        example = "America/New_York";
        description = "System timezone";
      };
      
      autoUpdateHardwareClock = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to automatically update the hardware clock";
      };
    };
    
    locale = {
      defaultLocale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "Default system locale";
      };
      
      extraLocales = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional locales to generate";
        example = [ "fr_FR.UTF-8" "de_DE.UTF-8" ];
      };
      
      supportedLocales = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "en_US.UTF-8/UTF-8" ];
        description = "Locales to be generated";
      };
    };
    
    console = {
      useXkbConfig = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use the X keyboard configuration for the console";
      };
      
      font = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Console font";
        example = "Lat2-Terminus16";
      };
      
      keyMap = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Console keymap";
        example = "us";
      };
    };
    
    fonts = {
      enable = lib.mkEnableOption "Enable system-wide fonts";
      
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
          liberation_ttf
          dejavu_fonts
        ];
        description = "Font packages to install";
      };
      
      fontconfig = {
        defaultFonts = {
          serif = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "DejaVu Serif" "Noto Serif" ];
            description = "Default serif fonts";
          };
          
          sansSerif = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "DejaVu Sans" "Noto Sans" ];
            description = "Default sans-serif fonts";
          };
          
          monospace = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "DejaVu Sans Mono" "Noto Sans Mono" ];
            description = "Default monospace fonts";
          };
          
          emoji = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "Noto Color Emoji" ];
            description = "Default emoji fonts";
          };
        };
      };
    };
    
    power = {
      enable = lib.mkEnableOption "Enable power management";
      
      powertop = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable powertop auto-tune";
      };
      
      tlp = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable TLP power management";
        };
        
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
          description = "TLP settings";
          example = {
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          };
        };
      };
    };
    
    packages = {
      base = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          coreutils
          curl
          wget
          git
          gnumake
          killall
          unzip
          gzip
          file
          which
          pciutils
          usbutils
          tree
        ];
        description = "Basic system packages to install";
      };
      
      extra = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional system packages to install";
      };
    };
    
    xdg = {
      portal = {
        enable = lib.mkEnableOption "Enable XDG desktop portal";
        extraPortals = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Additional portals to install";
        };
      };
      
      mime = {
        enable = lib.mkEnableOption "Configure XDG MIME applications";
        defaultApplications = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
          description = "Default MIME applications";
          example = {
            "application/pdf" = "org.gnome.Evince.desktop";
            "image/png" = "org.gnome.eog.desktop";
          };
        };
      };
    };
    
    services = {
      printing = {
        enable = lib.mkEnableOption "Enable CUPS printing";
        drivers = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = with pkgs; [ gutenprint hplip ];
          description = "Printer drivers to install";
        };
      };
      
      avahi = {
        enable = lib.mkEnableOption "Enable Avahi mDNS/DNS-SD stack";
        nssmdns = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable host name resolution through mDNS";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Set the state version
    system.stateVersion = cfg.stateVersion;
    
    # Time configuration
    time.timeZone = cfg.time.timeZone;
    services.timesyncd.enable = true;
    services.automatic-timezoned.enable = cfg.time.autoUpdateHardwareClock;
    
    # Locale configuration
    i18n.defaultLocale = cfg.locale.defaultLocale;
    i18n.extraLocaleSettings = {
      LC_TIME = cfg.locale.defaultLocale;
      LC_MONETARY = cfg.locale.defaultLocale;
      LC_PAPER = cfg.locale.defaultLocale;
      LC_MEASUREMENT = cfg.locale.defaultLocale;
    };
    i18n.supportedLocales = cfg.locale.supportedLocales 
      ++ map (loc: loc + "/UTF-8") cfg.locale.extraLocales;
    
    # Console configuration
    console = {
      useXkbConfig = cfg.console.useXkbConfig;
    } // lib.optionalAttrs (cfg.console.font != null) {
      font = cfg.console.font;
    } // lib.optionalAttrs (cfg.console.keyMap != null) {
      keyMap = cfg.console.keyMap;
    };
    
    # Fonts configuration
    fonts = lib.mkIf cfg.fonts.enable {
      packages = cfg.fonts.packages;
      fontconfig = {
        enable = true;
        defaultFonts = cfg.fonts.fontconfig.defaultFonts;
      };
    };
    
    # Power management
    powerManagement.enable = cfg.power.enable;
    powerManagement.powertop.enable = cfg.power.enable && cfg.power.powertop;
    services.tlp = lib.mkIf (cfg.power.enable && cfg.power.tlp.enable) {
      enable = true;
      settings = cfg.power.tlp.settings;
    };
    
    # System packages
    environment.systemPackages = cfg.packages.base ++ cfg.packages.extra;
    
    # XDG portal
    xdg.portal = lib.mkIf cfg.xdg.portal.enable {
      enable = true;
      extraPortals = cfg.xdg.portal.extraPortals;
      config.common.default = "*";
    };
    
    # XDG MIME applications
    xdg.mime = lib.mkIf cfg.xdg.mime.enable {
      enable = true;
      defaultApplications = cfg.xdg.mime.defaultApplications;
    };
    
    # Printing
    services.printing = lib.mkIf cfg.services.printing.enable {
      enable = true;
      drivers = cfg.services.printing.drivers;
    };
    
    # Avahi for service discovery
    services.avahi = lib.mkIf cfg.services.avahi.enable {
      enable = true;
      nssmdns = cfg.services.avahi.nssmdns;
      openFirewall = true;
    };
    
    # Enable documentation
    documentation = {
      enable = true;
      dev.enable = true;
      man = {
        enable = true;
        generateCaches = true;
      };
      info.enable = true;
    };
    
    # Program configuration
    programs = {
      command-not-found.enable = true;
      less.enable = true;
      mtr.enable = true;
    };
  };
}
