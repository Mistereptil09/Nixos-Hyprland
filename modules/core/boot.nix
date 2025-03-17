{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.boot;
in {
  options.modules.core.boot = {
    enable = lib.mkEnableOption "Enable boot configuration";
    
    loader = {
      type = lib.mkOption {
        type = lib.types.enum ["systemd-boot" "grub" "none"];
        default = "systemd-boot";
        description = "Boot loader to use";
      };
      
      timeout = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Boot menu timeout in seconds";
      };
      
      grub = {
        device = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/dev/sda";
          description = "Device to install GRUB on. Set to null for EFI";
        };
        
        efiSupport = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable EFI support in GRUB";
        };
        
        useOSProber = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable os-prober in GRUB";
        };
      };
      
      systemd-boot = {
        configurationLimit = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Maximum configurations in the boot menu";
        };
        
        editor = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to allow editing kernel command line";
        };
      };
    };
    
    kernelPackages = lib.mkOption {
      type = lib.types.package;
      default = pkgs.linuxPackages_latest;
      description = "Kernel packages to use";
    };
    
    kernelParams = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Kernel parameters";
    };
    
    plymouth = {
      enable = lib.mkEnableOption "Enable Plymouth boot splash";
      theme = lib.mkOption {
        type = lib.types.str;
        default = "breeze";
        description = "Plymouth theme to use";
      };
    };
    
    kernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Kernel modules to load";
    };
    
    tmpOnTmpfs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to mount /tmp on tmpfs";
    };
  };

  config = lib.mkIf cfg.enable {
    # Boot loader configuration
    boot.loader = {
      timeout = cfg.loader.timeout;
      
      # Configure systemd-boot
      systemd-boot = lib.mkIf (cfg.loader.type == "systemd-boot") {
        enable = true;
        configurationLimit = cfg.loader.systemd-boot.configurationLimit;
        editor = cfg.loader.systemd-boot.editor;
      };
      
      # Configure GRUB
      grub = lib.mkIf (cfg.loader.type == "grub") {
        enable = true;
        device = cfg.loader.grub.device;
        efiSupport = cfg.loader.grub.efiSupport;
        useOSProber = cfg.loader.grub.useOSProber;
      };
      
      # EFI support
      efi.canTouchEfiVariables = true;
    };
    
    # Kernel configuration
    boot.kernelPackages = cfg.kernelPackages;
    boot.kernelParams = cfg.kernelParams;
    boot.kernelModules = cfg.kernelModules;
    
    # Plymouth boot splash
    boot.plymouth = {
      enable = cfg.plymouth.enable;
      theme = cfg.plymouth.theme;
    };
    
    # Temporary filesystem
    boot.tmpOnTmpfs = cfg.tmpOnTmpfs;
    
    # Enable NTFS support
    boot.supportedFilesystems = [ "ntfs" ];
  };
}
