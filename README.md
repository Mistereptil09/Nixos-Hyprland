# Nixos-Hyprland

A simple, ready-to-use Hyprland configuration for NixOS with modular components.

## Quick Install

```bash
# Full installation (system + user, requires sudo)
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash

# Install only user configurations via home-manager
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | bash --user-only

# Install only system configurations (requires sudo)
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --system-only

# Install specific modules only
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --only desktop-system,apps

# Install everything except gaming components
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --exclude gaming-system,gaming-user

# Use Nix Flakes (recommended for better reproducibility)
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --flakes
```

## Available Modules

This configuration uses a clean separation between system and user-level components:

### System-level modules:
- `desktop-system` - Core Hyprland/Wayland system integration, display manager
- `gaming-system` - Gaming drivers, kernel optimizations, 32-bit libraries
- `system-utils` - System-level utilities and tools
- `security` - Security features and system services
- `virtualization` - VM and container support

### User-level modules:
- `desktop-user` - User-specific Hyprland configuration and desktop tools
- `apps` - User applications (browsers, office, etc.)
- `gaming-user` - Gaming applications and launchers
- `dev` - Development tools and languages
- `media` - Media creation and consumption tools
- `user-utils` - User-level utilities

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
sudo ./install.sh --flakes --exclude gaming-system,gaming-user,dev
```

## Module Organization

### Why this separation?
- **System level**: Contains services, drivers, and system-wide settings that require elevated privileges
- **User level**: Contains applications and configurations that don't require special system access

When you install modules like "desktop-system" and "desktop-user" together, you get a complete desktop environment with proper separation of concerns.

## Customization

- System-wide settings: `/etc/nixos/configuration.nix`
- User-specific settings: `~/.config/home-manager/home.nix`
- Keyboard layout: Set to `fr` by default - modify in both locations for consistency

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

## Keyboard Layout

This configuration uses **French (fr)** keyboard layout by default. To change it:

1. In the system configuration (`/etc/nixos/configuration.nix`):
   ```nix
   services.xserver = {
     layout = "fr";  # Change to your preferred layout (e.g., "us", "de")
     xkbVariant = "";  # Use variants like "dvorak" or "colemak" if needed
   };
   console.keyMap = "fr";  # Change to match your layout
   ```

2. In the Hyprland configuration (`~/.config/home-manager/modules/hyprland.nix`):
   ```nix
   input {
       kb_layout = fr  # Change to match system layout
       # ...other input settings...
   }
   ```

3. Rebuild your system after making these changes.

## Package Organization

This configuration carefully separates packages between system and user levels:

- **System-level packages**: Installed globally, include core services and drivers
- **User-level packages**: Managed through Home Manager, include applications used by the user

If you find duplicate packages installed at both levels, you can adjust the files in:
- System modules: `/etc/nixos/modules/`
- User modules: `~/.config/home-manager/modules/`

## Installation Examples

```bash
# Install complete desktop setup
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --only desktop-system,desktop-user,apps,dev

# Install only system components
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | sudo bash --system-only --only desktop-system,security

# Install only user components
curl -sSL https://raw.githubusercontent.com/yourusername/Nixos-Hyprland/main/install.sh | bash --user-only --only desktop-user,apps,dev
```