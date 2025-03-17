{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.hardware;
in {
  options.modules.core.hardware = {
    enable = lib.mkEnableOption "Enable hardware configuration";
    
    cpu = {
      intel.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable additional Intel CPU optimizations";
      };
      amd.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable additional AMD CPU optimizations";
      };
    };
    
    gpu = {
      intel.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable additional Intel GPU optimizations";
      };
      amd.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable additional AMD GPU optimizations";
      };
      nvidia = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable NVIDIA GPU support";
        };
        prime = {
          enable = lib.mkEnableOption "Enable NVIDIA PRIME";
          intelBusId = lib.mkOption {
            type = lib.types.str;
            default = "PCI:0:2:0";
            description = "Bus ID of the Intel GPU";
          };
          nvidiaBusId = lib.mkOption {
            type = lib.types.str;
            default = "PCI:1:0:0";
            description = "Bus ID of the NVIDIA GPU";
          };
        };
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
          description = "NVIDIA driver settings";
        };
      };
    };
    
    audio = {
      enable = lib.mkEnableOption "Enable audio support";
      pulseaudio = lib.mkEnableOption "Use PulseAudio instead of Pipewire";
    };
    
    bluetooth = {
      enable = lib.mkEnableOption "Enable Bluetooth support";
      powerOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Power on Bluetooth adapter on boot";
      };
    };
    
    opengl = {
      enable = lib.mkEnableOption "Enable OpenGL support";
      driSupport32Bit = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable 32-bit support for OpenGL";
      };
    };
    
    hardwareAcceleration = lib.mkEnableOption "Enable hardware acceleration";
    
    peripherals = {
      keyboard = {
        setXkbOptions = lib.mkEnableOption "Configure XKB keyboard options";
        xkbOptions = lib.mkOption {
          type = lib.types.str;
          default = "caps:escape";
          description = "XKB options string";
        };
        xkbLayout = lib.mkOption {
          type = lib.types.str;
          default = "us";
          description = "XKB layout string";
        };
        xkbVariant = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "XKB variant string";
        };
      };
      
      touchpad = {
        enable = lib.mkEnableOption "Enable touchpad support";
        naturalScrolling = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable natural scrolling";
        };
        tapping = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable tap to click";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # CPU-specific configurations - only apply when explicitly enabled
    (lib.mkIf cfg.cpu.intel.enable {
      hardware.cpu.intel.updateMicrocode = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    }),
    
    (lib.mkIf cfg.cpu.amd.enable {
      hardware.cpu.amd.updateMicrocode = true;
    }),

    # GPU-specific configurations - only apply when explicitly enabled
    (lib.mkIf cfg.gpu.intel.enable {
      hardware.opengl = {
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          libvdpau-va-gl
        ];
      };
    }),

    (lib.mkIf cfg.gpu.amd.enable {
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
      ];
    }),

    (lib.mkIf cfg.gpu.nvidia.enable {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
        settings = cfg.gpu.nvidia.settings;
        
        prime = lib.mkIf cfg.gpu.nvidia.prime.enable {
          intelBusId = cfg.gpu.nvidia.prime.intelBusId;
          nvidiaBusId = cfg.gpu.nvidia.prime.nvidiaBusId;
        };
      };
      
      hardware.opengl.extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    }),

    # Common OpenGL configuration
    (lib.mkIf cfg.opengl.enable {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = cfg.opengl.driSupport32Bit;
      };
    }),

    # Audio configuration
    (lib.mkIf cfg.audio.enable {
      sound.enable = true;
      security.rtkit.enable = true;
      
      services.pipewire = lib.mkIf (!cfg.audio.pulseaudio) {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
      
      hardware.pulseaudio = lib.mkIf cfg.audio.pulseaudio {
        enable = true;
        support32Bit = true;
      };
    }),

    # Bluetooth configuration 
    (lib.mkIf cfg.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = cfg.bluetooth.powerOnBoot;
      };
      services.blueman.enable = true;
    }),

    # Keyboard configuration
    (lib.mkIf cfg.peripherals.keyboard.setXkbOptions {
      services.xserver.xkb = {
        layout = cfg.peripherals.keyboard.xkbLayout;
        variant = cfg.peripherals.keyboard.xkbVariant;
        options = cfg.peripherals.keyboard.xkbOptions;
      };
    }),

    # Touchpad configuration
    (lib.mkIf cfg.peripherals.touchpad.enable {
      services.libinput = {
        enable = true;
        touchpad = {
          disableWhileTyping = true;
          tapping = cfg.peripherals.touchpad.tapping;
          naturalScrolling = cfg.peripherals.touchpad.naturalScrolling;
        };
      };
    }),

    # Group memberships
    {
      users.users.${config.user.name} = {
        extraGroups = 
          lib.optional cfg.audio.enable "audio" ++
          lib.optional cfg.bluetooth.enable "bluetooth";
      };
    }
  ]));
}
