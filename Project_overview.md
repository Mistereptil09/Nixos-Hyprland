# NixOS + Hyprland Architecture Documentation

## Architecture Overview

This configuration architecture organizes a NixOS system with Hyprland window manager using a functionality-first approach. The structure prioritizes code reuse, maintainability, and scalability across multiple machines.

![Architecture Diagram](https://placeholder-for-diagram.com)

### Core Principles

1. **Functionality-Based Organization**: Modules are organized by functionality rather than by system/user boundaries
2. **Single Source of Truth**: Each functionality is configured in one place, handling both system and user aspects
3. **Composable Profiles**: Common configurations are grouped into reusable profiles
4. **Clear Separation of Concerns**: Common, host-specific, and user-specific settings are cleanly separated

## How It Works

### 1. Module System

Modules represent discrete functionalities (e.g., window manager, terminal, development tools). Each module:
- Defines configuration options
- Implements both system and user configurations when enabled
- Manages its dependencies

### 2. Profile System

Profiles combine multiple modules with sensible defaults to create complete configurations (e.g., desktop workstation, development environment). 

### 3. Host Configuration

Host configurations import profiles and override specific settings for each machine.

### 4. Common Utilities

Shared code, theme definitions, and utility functions live in the `common/` directory.

## Main Objectives and Implementation

| Objective | Implementation |
|-----------|----------------|
| **Reduce Duplication** | Functionality modules combine system and user configurations |
| **Improve Maintainability** | Single location for each component's configuration |
| **Enable Code Reuse** | Common modules, profiles, and utility functions |
| **Support Multiple Machines** | Host-specific configurations with shared base |
| **Ensure Consistency** | Centralized theming and shared options |
| **Allow Local Customization** | Non-versioned override mechanism |

## Constraints and Considerations

- **Learning Curve**: Requires understanding how system and home-manager configurations interact
- **Abstraction Complexity**: Some additional indirection compared to simpler approaches
- **Integration Requirements**: Home-manager must be configured as a NixOS module

## Pros and Cons

### Pros
- **DRY Code**: Significantly reduces repetition across configurations
- **Coherent Management**: Related settings stay together regardless of where they apply
- **Easier Updates**: Change one module to update functionality across all hosts
- **Clearer Dependencies**: Module system exposes and manages dependencies
- **Flexible Theming**: Centralized theme applies consistently across all applications

### Cons
- **More Complex**: More abstraction than traditional NixOS configurations
- **Less Standard**: Deviates from common NixOS configuration patterns
- **Tighter Coupling**: System and user configurations become more interdependent
- **Initial Setup Time**: Takes longer to set up initially compared to simpler approaches

## File Examples

### 1. Module Definition

```nix
# modules/desktop/hyprland.nix

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.desktop.hyprland;
in {
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland window manager";
    
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Hyprland configuration";
    };
    
    defaultTerminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level configuration
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    
    environment.systemPackages = with pkgs; [
      hyprpaper
      wl-clipboard
      (lib.getBin pkgs.${cfg.defaultTerminal})
    ];
    
    # XDG Portal required for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
    
    # User-level configuration via home-manager
    home-manager.users.${config.user.name} = { ... }: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = {
          # Default settings
          exec-once = [
            "hyprpaper" 
            "waybar"
          ];
          
          bind = [
            "SUPER, Return, exec, ${cfg.defaultTerminal}"
            "SUPER, Q, killactive,"
          ];
        };
        extraConfig = cfg.extraConfig;
      };
    };
  };
}
```

### 2. System Base Profile

```nix
# nixos/profiles/base.nix

{ config, lib, pkgs, ... }:

{
  # Import common modules
  imports = [
    ../../modules/core
  ];
  
  # Define the user option
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
  
  # Base system configuration
  config = {
    # Enable base modules
    modules.core = {
      nix.enable = true;
      boot.enable = true;
      networking.enable = true;
    };
    
    # Common system settings
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
    
    # Create user
    users.users.${config.user.name} = {
      isNormalUser = true;
      description = config.user.description;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    };
    
    # Basic packages that should be available everywhere
    environment.systemPackages = with pkgs; [
      git
      vim
      curl
      wget
    ];
  };
}
```

### 3. User Base Profile

```nix
# home-manager/profiles/base.nix

{ config, lib, pkgs, ... }:

{
  # Import common user modules
  imports = [
    ../../modules/shell
  ];
  
  # Base user configuration
  config = {
    # Enable shell modules
    modules.shell = {
      zsh.enable = true;
      git.enable = true;
      tmux.enable = true;
    };
    
    # Common home-manager settings
    home = {
      stateVersion = "23.11";
      
      sessionVariables = {
        EDITOR = "vim";
        TERMINAL = "kitty";
      };
      
      packages = with pkgs; [
        ripgrep
        fd
        bat
        htop
      ];
    };
    
    # Standard programs configuration 
    programs = {
      home-manager.enable = true;
    };
  };
}
```

### 4. Host Configuration

```nix
# hosts/laptop/default.nix

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/default.nix   # Common host settings
    ./hardware.nix          # Hardware-specific settings
    ../../nixos/profiles/desktop.nix  # Desktop profile
  ];
  
  # Basic system configuration
  networking.hostName = "nixos-laptop";
  user.name = "alice";
  
  # Host-specific module customization
  modules = {
    desktop = {
      hyprland = {
        enable = true;
        extraConfig = ''
          # Laptop-specific Hyprland config
          monitor=eDP-1,1920x1080@60,0x0,1
          
          # Laptop-specific keybindings
          bind=,XF86MonBrightnessUp,exec,light -A 5
          bind=,XF86MonBrightnessDown,exec,light -U 5
        '';
      };
      
      # Enable laptop-specific modules
      power.enable = true;
      touchpad.enable = true;
    };
  };
  
  # Include home configuration
  home-manager.users.alice = import ./home.nix;
}
```

### 5. Theme Configuration

```nix
# common/modules/theme.nix

{ config, lib, ... }:

{
  options.theme = {
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = {
        primary = "#5294e2";
        secondary = "#5cb85c";
        background = "#383c4a";
        foreground = "#d3dae3";
        alert = "#d23c3d";
      };
      description = "Color scheme for the system";
    };
    
    fonts = lib.mkOption {
      type = lib.types.attrs;
      default = {
        monospace = "JetBrainsMono Nerd Font";
        sans = "Noto Sans";
        serif = "Noto Serif";
        sizes = {
          small = 10;
          normal = 12;
          large = 14;
        };
      };
      description = "Font configuration";
    };
    
    assets = lib.mkOption {
      type = lib.types.attrs;
      default = {
        wallpaperDir = ../assets/wallpapers;
        defaultWallpaper = ../assets/wallpapers/default.png;
      };
      description = "Asset paths";
    };
  };
}
```

## Workflow Examples

### Setting Up a New Host

1. Create a new directory under `hosts/`
2. Create hardware configuration specific to the host
3. Create a default.nix that imports appropriate profiles
4. Add host-specific overrides to module settings
5. Add to flake.nix as a new system

### Adding a New Module

1. Create a new module file in the appropriate functionality directory
2. Define options and implement configurations
3. Import the module in relevant profiles
4. Enable and customize in host configurations as needed

### Creating a Custom Theme

1. Create a theme override file
2. Import and override the values in `common/modules/theme.nix`
3. Apply in host configuration

## Best Practices

1. **Keep Modules Focused**: Each module should handle one specific functionality
2. **Explicit Dependencies**: Use assertions to enforce module dependencies
3. **Parameterize Everything**: Expose configuration options rather than hardcoding values
4. **Test Configurations**: Regularly test that configurations build without errors
5. **Document Non-Standard Patterns**: Add comments for complex or unusual configurations
6. **Use Local Overrides**: Avoid committing machine-specific tweaks to the repository

## Troubleshooting

### Common Issues

1. **Module Not Applied**: Ensure the module is both imported and enabled
2. **Configuration Conflicts**: Check for overlapping settings in different modules
3. **Missing Dependencies**: Verify all required modules are enabled
4. **Order Problems**: Consider using assertions or explicit dependencies

### Debugging Tips

1. Use `--show-trace` with Nix commands to see error sources
2. Check module options with `nixos-option modules.<name>`
3. Temporarily disable problematic modules to isolate issues


To provide practical examples of how this architecture works in practice, let me share some key implementation details for the most important files:

```nix
# flake.nix - The entry point for the configuration

{
  description = "NixOS + Hyprland Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      
      # Function to create a NixOS system configuration
      mkHost = { 
        system ? "x86_64-linux",
        hostname, 
        username ? "user",
        modules ? [] 
      }: lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs hostname username; 
        };
        
        modules = [
          # Enable home-manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          
          # Import common configuration
          ./hosts/common/default.nix
          
          # Include user-provided modules
        ] ++ modules;
      };
    in {
      nixosConfigurations = {
        # Laptop configuration
        laptop = mkHost {
          hostname = "nixos-laptop";
          username = "alice";
          modules = [
            ./hosts/laptop/default.nix
          ];
        };
        
        # Desktop configuration
        desktop = mkHost {
          hostname = "nixos-desktop";
          username = "alice";
          modules = [
            ./hosts/desktop/default.nix
          ];
        };
      };
    };
}

# modules/desktop/hyprland.nix - Example functionality module

{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.desktop.hyprland;
  username = config.user.name;
in {
  # Import hyprland module from flake
  imports = [
    inputs.hyprland.nixosModules.default
  ];
  
  # Module options
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland window manager";
    
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = config.theme.assets.defaultWallpaper;
      description = "Wallpaper for Hyprland";
    };
    
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };
    
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Hyprland configuration";
    };
  };
  
  # Module implementation
  config = lib.mkIf cfg.enable {
    # Ensure dependencies are met
    assertions = [{
      assertion = config.xdg.portal.enable;
      message = "Hyprland requires XDG portal to be enabled";
    }];
    
    # System-level configuration
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    
    environment.systemPackages = with pkgs; [
      hyprpaper
      wl-clipboard
      grim
      slurp
    ];
    
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
    
    # User-level configuration via home-manager
    home-manager.users.${username} = { ... }: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = {
          monitor = "eDP-1,1920x1080@60,0x0,1";
          
          exec-once = [
            "hyprpaper"
            "waybar"
          ];
          
          bind = [
            "SUPER, Return, exec, ${cfg.terminal}"
            "SUPER, Q, killactive,"
            "SUPER, M, exit,"
            "SUPER, V, togglefloating,"
            "SUPER, Space, exec, wofi --show drun"
          ];
          
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            "col.active_border" = config.theme.colors.primary;
            "col.inactive_border" = config.theme.colors.background;
          };
        };
        
        extraConfig = ''
          # Set wallpaper
          exec-once = hyprpaper -c ${cfg.wallpaper}
          
          # Custom configuration
          ${cfg.extraConfig}
        '';
      };
      
      # Set up hyprpaper
      home.file.".config/hypr/hyprpaper.conf".text = ''
        preload = ${cfg.wallpaper}
        wallpaper = eDP-1,${cfg.wallpaper}
      '';
    };
  };
}

# nixos/profiles/desktop.nix - System desktop profile

{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  # Enable desktop modules
  modules.desktop = {
    hyprland.enable = true;
    waybar.enable = true;
    notifications.enable = true;
    audio.enable = true;
    bluetooth.enable = true;
  };
  
  # Common desktop settings
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      noto-fonts
      noto-fonts-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "${config.theme.fonts.monospace}" ];
      sansSerif = [ "${config.theme.fonts.sans}" ];
      serif = [ "${config.theme.fonts.serif}" ];
    };
  };
  
  # Enable common desktop services
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      displayManager.defaultSession = "hyprland";
    };
  };
  
  # Desktop-specific packages
  environment.systemPackages = with pkgs: [
    firefox
    gnome.nautilus
    gnome.adwaita-icon-theme
  ];
}

# home-manager/profiles/desktop.nix - User desktop profile

{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  
  # Configure desktop applications
  programs = {
    kitty = {
      enable = true;
      font = {
        name = config.theme.fonts.monospace;
        size = config.theme.fonts.sizes.normal;
      };
      settings = {
        background = config.theme.colors.background;
        foreground = config.theme.colors.foreground;
      };
    };
    
    wofi = {
      enable = true;
      settings = {
        width = 500;
        height = 300;
        location = "center";
        show = "drun";
        prompt = "Search...";
      };
      style = ''
        * {
          font-family: ${config.theme.fonts.sans};
          font-size: ${toString config.theme.fonts.sizes.normal}px;
        }
        
        window {
          background-color: ${config.theme.colors.background};
          color: ${config.theme.colors.foreground};
        }
      '';
    };
  };
  
  # Desktop-specific user packages
  home.packages = with pkgs; [
    papirus-icon-theme
    xdg-utils
    libnotify
  ];
}

# hosts/laptop/default.nix - Example host configuration

{ config, lib, pkgs, hostname, username, ... }:

{
  imports = [
    ./hardware.nix
    ../../nixos/profiles/desktop.nix
  ];
  
  # Basic system configuration
  networking.hostName = hostname;
  user.name = username;
  
  # Laptop-specific module customization
  modules.desktop = {
    hyprland = {
      extraConfig = ''
        # Laptop-specific Hyprland config
        bind=,XF86MonBrightnessUp,exec,light -A 5
        bind=,XF86MonBrightnessDown,exec,light -U 5
        bind=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +5%
        bind=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -5%
        bind=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle
      '';
    };
    
    # Enable laptop-specific modules
    power = {
      enable = true;
      criticalBattery = 10;
      lowBattery = 15;
    };
  };
  
  # Hardware-specific settings
  hardware.acpilight.enable = true;
  
  # Include home configuration
  home-manager.users.${username} = import ./home.nix;
}

# common/modules/theme.nix - Central theming module

{ config, lib, ... }:

{
  options.theme = {
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = {
        primary = "#5294e2";
        secondary = "#5cb85c";
        background = "#383c4a";
        foreground = "#d3dae3";
        alert = "#d23c3d";
      };
      description = "Color scheme for the system";
    };
    
    fonts = lib.mkOption {
      type = lib.types.attrs;
      default = {
        monospace = "JetBrainsMono Nerd Font";
        sans = "Noto Sans";
        serif = "Noto Serif";
        sizes = {
          small = 10;
          normal = 12;
          large = 14;
        };
      };
      description = "Font configuration";
    };
    
    assets = lib.mkOption {
      type = lib.types.attrs;
      default = {
        wallpaperDir = ../../assets/wallpapers;
        defaultWallpaper = ../../assets/wallpapers/default.png;
      };
      description = "Asset paths";
    };
  };
}

# common/lib/merge-configs.nix - Example utility function

{ lib, ... }:

{
  # Recursively merge two attribute sets
  mergeConfigs = baseConfig: overrides: lib.recursiveUpdate baseConfig overrides;
  
  # Make an application config that spans system and user boundaries
  makeAppConfig = { name, systemDefaults ? {}, userDefaults ? {}, systemOverrides ? {}, userOverrides ? {} }: {
    systemConfig = lib.recursiveUpdate systemDefaults systemOverrides;
    userConfig = lib.recursiveUpdate userDefaults userOverrides;
  };
}

```

This architecture is designed to solve several key challenges in NixOS configuration:

1. **Keeping related configurations together**: Instead of splitting system-level and user-level configurations across different files, each functional module contains both aspects.

2. **Reducing duplication**: Common settings are defined once and shared across hosts.

3. **Simplifying multi-host management**: The structure makes it easy to have consistent configurations across multiple machines while allowing for host-specific customizations.

The main strengths of this approach are:

- **Modularity**: Each functionality is self-contained and independently toggleable
- **Reusability**: Configurations can be easily shared across machines
- **Maintainability**: Changes to a functionality only need to be made in one place
- **Consistency**: Centralized theming and configuration options ensure a unified experience

The main challenges are:

- **Complexity**: The structure introduces more abstraction than simple NixOS configurations
- **Learning curve**: Understanding how the pieces fit together takes more time initially
- **Non-standard approach**: It diverges from the typical NixOS configuration patterns

For someone implementing this system, the key files to understand are:
1. `flake.nix` - The entry point that defines systems and imports everything
2. Functionality modules (like `modules/desktop/hyprland.nix`) - Define and implement specific features
3. Profiles (like `nixos/profiles/desktop.nix`) - Combine modules for specific use-cases
4. Host configurations (like `hosts/laptop/default.nix`) - Customize for specific machines

This architecture shines in multi-host environments where you want consistent configurations with minimal duplication, while still allowing for machine-specific customizations.


# file tree structure :
```sh
/project_root
├── flake.nix           # Entry point with system definitions
├── flake.lock
├── README.md
├── modules/       # Functionality-based modules
│   ├── profiles/       # Meta-modules that enable collections of modules
│   │   ├── nixos/      # System profile meta-modules
│   │   │   ├── base.nix      # Base system profile
│   │   │   └── desktop.nix   # Desktop system profile
│   │   └── home/       # User profile meta-modules
│   │       ├── base.nix      # Base user profile
│   │       └── desktop.nix   # Desktop user profile     
│   ├── core/           # Core system configuration
│   │   ├── default.nix # Import point for all core modules
│   │   ├── nix.nix     # Nix package manager configuration
│   │   ├── boot.nix    # Boot loader and early system boot settings
│   │   └── networking.nix # Basic network configuration and settings
│   ├── shell/          # Shell environment configuration
│   │   ├── default.nix # Import point for shell modules
│   │   ├── zsh/        # Z-shell configuration
│   │   │   ├── default.nix # Options definition and import point
│   │   │   ├── install.nix # System-level ZSH installation
│   │   │   └── config.nix  # User dotfiles and ZSH configuration
│   │   ├── git/        # Git version control
│   │   │   ├── default.nix # Git module options and imports
│   │   │   ├── install.nix # System git installation
│   │   │   └── config.nix  # User-specific git configuration
│   │   └── tmux/       # Terminal multiplexer
│   │       ├── default.nix # Tmux module options and imports
│   │       ├── install.nix # System tmux installation
│   │       └── config.nix  # User tmux configuration and keybindings
│   ├── hyprland/       # Hyprland window manager environment
│   │   ├── default.nix # Main Hyprland environment options
│   │   ├── install.nix # Core Hyprland system installation
│   │   ├── config.nix  # Basic Hyprland window manager configuration
│   │   ├── shortcuts.nix # Hyprland keybindings and shortcuts
│   │   └── apps/       # Hyprland-specific applications
│   │       ├── wofi/   # Application launcher for Wayland
│   │       │   ├── default.nix # Wofi module options
│   │       │   ├── install.nix # Install wofi launcher
│   │       │   └── config.nix  # Wofi styling and configuration
│   │       ├── waybar/ # Status bar for Hyprland
│   │       │   ├── default.nix # Waybar module options
│   │       │   ├── install.nix # Install waybar and dependencies
│   │       │   └── config.nix  # Waybar styling and layout
│   │       └── terminal/ # Terminal emulator for Hyprland
│   │           ├── default.nix # Terminal module options
│   │           ├── install.nix # Install preferred terminal
│   │           └── config.nix  # Terminal appearance and behavior
│   ├── development/    # Development tools and environments
│   │   ├── default.nix # Common development options
│   │   ├── virtualization/ # Virtualization and containers
│   │   │   ├── default.nix # Virtualization module options
│   │   │   ├── docker.nix  # Docker container engine
│   │   │   ├── podman.nix  # Podman container engine
│   │   │   └── kvm.nix     # KVM/QEMU virtual machines
│   │   ├── languages/  # Programming language environments
│   │   │   ├── default.nix # Language environment options
│   │   │   ├── python.nix  # Python development environment
│   │   │   ├── rust.nix    # Rust development environment
│   │   │   ├── node.nix    # Node.js/JavaScript environment
│   │   │   └── go.nix      # Go development environment
│   │   ├── editors/    # Code editors and IDEs
│   │   │   ├── default.nix # Editors common settings
│   │   │   ├── vscode/     # Visual Studio Code
│   │   │   │   ├── default.nix # VS Code options
│   │   │   │   ├── install.nix # VS Code installation
│   │   │   │   └── config.nix  # VS Code settings and extensions
│   │   │   └── neovim/     # Neovim editor
│   │   │       ├── default.nix # Neovim options
│   │   │       ├── install.nix # Neovim installation
│   │   │       └── config.nix  # Neovim configuration and plugins
│   │   └── tools/      # Development tools
│   │       ├── default.nix # Development tools options
│   │       ├── devops.nix  # DevOps tools (terraform, etc)
│   │       └── api.nix     # API development tools (Postman, Insomnia)
│   ├── multimedia/     # Media creation and consumption
│   │   ├── default.nix # Multimedia module options
│   │   ├── image.nix   # Image editing tools (GIMP, etc)
│   │   ├── video.nix   # Video tools (VLC, Kdenlive, etc)
│   │   ├── audio.nix   # Audio tools (Audacity, etc)
│   │   └── streaming.nix # Streaming tools (OBS, etc)
│   ├── productivity/   # Work and productivity applications
│   │   ├── default.nix # Productivity module options
│   │   ├── office.nix  # Office suites (LibreOffice, OnlyOffice)
│   │   └── research.nix # Research tools (Zotero, etc)
│   ├── utilities/      # System utilities
│   │   ├── default.nix # Import point for utilities
│   │   ├── backups/    # Backup solutions
│   │   │   ├── default.nix # Backup module options
│   │   │   ├── install.nix # Backup tools installation
│   │   │   └── config.nix  # Backup configuration
│   │   ├── screenshots/ # Screen capture utilities
│   │   │   ├── default.nix # Screenshot module options
│   │   │   ├── install.nix # Install screenshot tools
│   │   │   └── config.nix  # Configure screenshot behavior
│   │   ├── system.nix  # System maintenance tools (bleachbit, etc)
│   │   └── file-management.nix # File managers and utilities
│   ├── networking/     # Advanced networking modules
│   │   ├── default.nix # Networking module options
│   │   ├── vpn.nix     # VPN clients (Wireguard, OpenVPN)
│   │   └── analysis.nix # Network analysis (Wireshark, etc)
│   ├── security/       # Security applications
│   │   ├── default.nix # Security module options
│   │   ├── passwords.nix # Password managers (KeePassXC, etc)
│   │   └── scanning.nix  # Security scanning tools (ClamAV, etc)
│   ├── communication/  # Communication tools
│   │   ├── default.nix # Communication module options
│   │   ├── messaging.nix # Messaging apps (Signal, Element, etc)
│   │   └── conferencing.nix # Video conferencing (Zoom, etc)
│   └── gaming/         # Gaming applications
│       ├── default.nix # Gaming module options
│       ├── steam.nix   # Steam and native games
│       └── emulation.nix # Game emulation (Wine, Lutris, etc)
├── hosts/              # Host-specific configurations
│   ├── common/         # Common host settings
│   │   └── default.nix
│   ├── hyprland_laptop/         # Laptop configuration
│   │   ├── default.nix   # Main configuration
│   │   ├── hardware.nix  # Hardware-specific configuration
│   │   └── home.nix      # Host-specific home-manager config
│   └── hyprland_desktop/        # Desktop configuration
│       ├── default.nix
│       ├── hardware.nix
│       └── home.nix
├── common/             # Common utilities and theme
│   ├── modules/
│   │   └── theme.nix     # Central theming module
│   └── lib/
│       └── merge-configs.nix  # Utility functions
└── assets/             # Assets like wallpapers
    └── wallpapers/
        └── default.png
```

### Tier 1: Simple One-files Modules
**For simple modules**
```sh
common/             # Common utilities and theme
├── modules/
│   └── theme.nix     # Central theming module
└── lib/
```

- Don't require complex installation steps
- Have minimal user-facing configuration

**Example structure:**
```nix
# Single file module: modules/core/networking.nix
{ config, lib, pkgs, ... }:

  options.modules.core.networking = {
    enable = lib.mkEnableOption "Enable networking configuration";
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Machine hostname";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      hostName = cfg.hostName;
      networkmanager.enable = true;
    };
  };
}
```

### Tier 2: Medium Complexity Modules
**For modules with moderate configuration needs**

```sh
modules/shell/zsh/
├── default.nix    # Main entry point with options
├── install.nix    # Package installation
└── config.nix     # Configuration
```

Medium complexity modules split functionality into multiple files when they:
- Have many configuration options
- Need to install multiple packages
- Configure multiple aspects of a system
- Generate complex configuration files

**Example structure:**
```nix
# Entry point: modules/shell/zsh/default.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
  ];

  options.modules.shell.zsh = {
    enable = lib.mkEnableOption "Enable Zsh shell";
    defaultPrompt = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use the default prompt configuration";
    };
  };
}

# Installation: modules/shell/zsh/install.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.shell.zsh;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      zsh-syntax-highlighting
      zsh-autosuggestions
    ];
    users.defaultUserShell = pkgs.zsh;
  };
}

# Configuration: modules/shell/zsh/config.nix
{ config, lib, ... }:

let
  cfg = config.modules.shell.zsh;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users.${config.user.name} = { ... }: {
      programs.zsh = {
        enable = true;
        autocd = true;
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
        # ... other config options
      };
    };
  };
}
```

### Tier 3: Complex Modules with Submodules
**For core environment modules with many components**

```
modules/hyprland/
├── default.nix    # Main entry point
├── install.nix    # Core package installation
├── config.nix     # Core configuration
├── shortcuts.nix  # Key bindings
└── apps/          # Related applications
    ├── wofi/
    ├── waybar/
    └── terminal/
```

Complex modules use a multi-level structure when they:
- Configure an entire environment with multiple related applications
- Handle complex interactions between components
- Need specialized configuration files for different aspects
- Manage submodules that can be enabled/disabled independently

**Example structure:**
```nix
# Main entry point: modules/hyprland/default.nix
{ config, lib, ... }:

{
  imports = [
    ./install.nix
    ./config.nix
    ./shortcuts.nix
    ./apps/wofi
    ./apps/waybar
    ./apps/terminal
  ];
  
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland desktop environment";
    
    # Global options affecting multiple submodules
    theme = lib.mkOption {
      type = lib.types.enum [ "dark" "light" ];
      default = "dark";
      description = "Theme to use across Hyprland components";
    };
  };
}
```

This tiered approach balances simplicity and organization, using the appropriate structure based on the complexity of each module.

## Profile Management

### Understanding Profiles

Profiles are collections of modules with sensible defaults that serve as building blocks for your system configuration. The architecture maintains two types of profiles:

1. **System Profiles** (`nixos/profiles/`): Configure system-wide aspects including:
   - Core system settings
   - Hardware support
   - System services
   - Global packages

2. **User Profiles** (`home-manager/profiles/`): Configure user-specific aspects including:
   - User applications
   - Dotfiles
   - Shell configurations
   - Personal preferences

### Why Two Profile Types?

Despite modules combining system and user configurations, separate profile types offer:

- **Selective Application**: Apply different profiles to different users on the same system
- **Independent Management**: Update user environments without changing system configuration
- **Clean Separation**: Keep purely system and purely user settings organized
- **Multi-User Support**: Configure multiple users with different preferences

### Creating and Combining Profiles

Profiles can be created to match specific use cases:

```nix
# nixos/profiles/development.nix
{ ... }:

{
  imports = [
    ./base.nix  # Import base system profile
  ];
  
  # Enable development modules
  modules.dev = {
    base.enable = true;
    python.enable = true;
    rust.enable = true;
    editors.vscode.enable = true;
  };
  
  # Development-specific system settings
  virtualisation.docker.enable = true;
}
```

For user-specific development settings:

```nix
# home-manager/profiles/development.nix
{ ... }:

{
  imports = [
    ./base.nix  # Import base user profile
  ];
  
  # User development settings
  home.packages = with pkgs; [
    jetbrains.idea-community
    postman
    insomnia
  ];
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Developer";
    userEmail = "dev@example.com";
  };
}
```

### Mixing and Matching Profiles

Profiles can be combined at the host level for maximum flexibility:

1. **Composite User Profiles**:
   ```nix
   # home-manager/profiles/full-workstation.nix
   { ... }:
   
   {
     imports = [
       ./desktop.nix       # Desktop environment
       ./development.nix   # Development tools
       ./creative.nix      # Creative applications
     ];
   }
   ```

2. **Direct Host Configuration**:
   ```nix
   # hosts/workstation/default.nix
   {
     imports = [
       ../../nixos/profiles/desktop.nix
       ../../nixos/profiles/development.nix
     ];
     
     home-manager.users.${config.user.name} = { ... }: {
       imports = [
         ../../home-manager/profiles/desktop.nix
         ../../home-manager/profiles/development.nix
       ];
     };
   }
   ```

3. **Selective Module Enablement**:
   ```nix
   # Enable only specific modules from profiles
   modules = {
     desktop = {
       hyprland.enable = true;
       waybar.enable = true;
       # Disable other desktop modules
       notifications.enable = false;
     };
     
     dev = {
       python.enable = true;
       # Disable other dev modules
       rust.enable = false;
     };
   };
   ```

### Best Practices

1. **Keep Profiles Focused**: Each profile should serve a specific purpose
2. **Prefer Composition**: Build larger profiles by importing smaller ones
3. **Avoid Deep Nesting**: Limit profile import depth to maintain clarity
4. **Test Combinations**: Verify that combined profiles don't conflict
5. **Document Dependencies**: Make profile requirements explicit
6. **Provide Sensible Defaults**: Profiles should work well out-of-the-box

This profile system creates a flexible foundation that scales from simple single-user systems to complex multi-host, multi-user deployments.