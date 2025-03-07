# Nixos-Hyprland

A simple, ready-to-use Hyprland configuration for NixOS with modular components.

## Quick Install

```bash
# Full installation (requires sudo)
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash

# Install user configuration only
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | bash --user-only

# Install specific modules only
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --only hyprland,app

# Install everything except gaming components
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --exclude games

# Use Nix Flakes (recommended for better reproducibility)
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --flakes
```

## Available Modules

- `hyprland` - Hyprland window manager and core components
- `app` - Common applications for everyday use
- `games` - Gaming software, emulators, and optimizations
- `dev` - Development tools, languages, and services
- `media` - Media creation and consumption software
- `security` - Security tools and configurations
- `virtualization` - Virtual machine and container tools

## Features

- Pre-configured Hyprland window manager
- Waybar with practical layout
- Wofi launcher (replaces Rofi for better Wayland compatibility) 
- Simple keybindings
- Modular configuration for easy customization
- Home Manager integration for user-specific configurations
- Nix Flakes support for reproducible builds

## Manual Installation

If you prefer to review the script before executing:

```bash
# Download the install script
curl -O https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh

# Make it executable
chmod +x install.sh

# Review it
nano install.sh

# See available modules
./install.sh --list-modules

# Run it with your preferred options
sudo ./install.sh --flakes --exclude games,dev
```

## Customization

! Default keyboard layout is `fr`, you can change it into `configuration.nix` and `hyprland.nix` (you must change it in both at once)

Edit the following files to customize your setup:

- System configuration: `/etc/nixos/configuration.nix`
- Module selection: `/etc/nixos/modules/imports.nix`
- Flakes configuration: `/etc/nixos/flake.nix` (if using flakes)
- Home Manager configuration: `~/.config/home-manager/home.nix`
- Hyprland configuration: `~/.config/hypr/hyprland.conf`
- Waybar configuration: `~/.config/waybar/config`

## Using with Home Manager

This configuration includes Home Manager integration for managing user-specific packages and configurations:

```bash
# To update your Home Manager configuration:
home-manager switch

# To update your NixOS configuration with flakes:
sudo nixos-rebuild switch --flake /etc/nixos#your-hostname
```

## Using with Flakes

This configuration supports Nix Flakes for reproducible builds and easier management:

```bash
# Installing with flakes
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --flakes

# Updating your system with flakes
sudo nixos-rebuild switch --flake /etc/nixos#your-hostname

# Using standalone home-manager with flakes
home-manager switch --flake ~/.config/home-manager#your-username
```

### Flake Structure

The flake.nix provided includes:

- NixOS system configuration
- Home Manager integration
- Hyprland from upstream
- Multiple architecture support
- Development shells for maintaining the configuration

### Customizing Flakes

To customize your flake configuration:

1. Edit your system flake: `/etc/nixos/flake.nix`
2. Add additional inputs like:
   ```nix
   inputs = {
     # ...existing inputs...
     nixvim.url = "github:nix-community/nixvim";
     catppuccin.url = "github:catppuccin/nix";
   };
   ```
3. Use these inputs in your configuration:
   ```nix
   # In your modules
   { inputs, ... }: {
     imports = [ inputs.nixvim.nixosModules.nixvim ];
   }
   ```