#!/usr/bin/env bash
# filepath: /workspaces/Nixos-Hyprland/install.sh

set -e

echo "=== NixOS Hyprland Configuration Installer ==="

# Configuration
REPO_URL="https://github.com/yourusername/Nixos-Hyprland.git"
TEMP_DIR="$(mktemp -d)"
NIXOS_CONFIG_DIR="/etc/nixos"
CONFIG_DIR="$HOME/.config"
AVAILABLE_MODULES=("hyprland" "app" "games" "dev" "media" "security" "virtualization")
USE_FLAKES=0
USERNAME=""
HOST_NAME=""

# Initialize with all modules
SELECTED_MODULES=("${AVAILABLE_MODULES[@]}")
ONLY_MODULES=()
EXCLUDE_MODULES=()

# Module dependencies
declare -A MODULE_DEPS
MODULE_DEPS["dev"]="virtualization" # dev depends on virtualization
MODULE_DEPS["games"]="security"     # games might depend on security for Steam

cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --user-only                Install only user configurations, not system configurations"
    echo "  --only MODULE1,MODULE2     Only install specified modules (comma-separated)"
    echo "  --exclude MODULE1,MODULE2  Exclude specified modules (comma-separated)"
    echo "  --list-modules             List available modules"
    echo "  --flakes                   Use flakes-based configuration"
    echo "  --local PATH               Use local files instead of cloning repository"
    echo "  --help                     Show this help message"
    echo ""
    echo "Available modules: ${AVAILABLE_MODULES[*]}"
    echo ""
    echo "Examples:"
    echo "  $0 --only hyprland,app     # Only install hyprland and app modules"
    echo "  $0 --exclude games,media   # Install all modules except games and media"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --user-only)
            USER_ONLY=1
            shift
            ;;
        --only)
            IFS=',' read -ra ONLY_MODULES <<< "$2"
            SELECTED_MODULES=("${ONLY_MODULES[@]}")
            shift 2
            ;;
        --exclude)
            IFS=',' read -ra EXCLUDE_MODULES <<< "$2"
            # Filter out excluded modules
            for module in "${EXCLUDE_MODULES[@]}"; do
                SELECTED_MODULES=("${SELECTED_MODULES[@]/$module/}")
            done
            # Clean up empty elements
            SELECTED_MODULES=("${SELECTED_MODULES[@]}")
            shift 2
            ;;
        --list-modules)
            echo "Available modules:"
            for module in "${AVAILABLE_MODULES[@]}"; do
                echo " - $module"
            done
            exit 0
            ;;
        --flakes)
            USE_FLAKES=1
            shift
            ;;
        --local)
            LOCAL_PATH="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if running as root for NixOS config changes
if [[ $EUID -ne 0 && -z "$USER_ONLY" ]]; then
    echo "This script needs to be run as root to modify system configuration."
    echo "Run with --user-only to only install user configurations."
    exit 1
fi

# Validate selected modules
for module in "${SELECTED_MODULES[@]}"; do
    if [[ ! " ${AVAILABLE_MODULES[*]} " =~ " ${module} " && -n "$module" ]]; then
        echo "Error: Unknown module '$module'"
        echo "Available modules: ${AVAILABLE_MODULES[*]}"
        exit 1
    fi
done

# Fix module exclusion to properly filter the array
if [[ ${#EXCLUDE_MODULES[@]} -gt 0 ]]; then
    TEMP_MODULES=()
    for module in "${SELECTED_MODULES[@]}"; do
        exclude=0
        for ex_module in "${EXCLUDE_MODULES[@]}"; do
            [[ "$module" == "$ex_module" ]] && exclude=1 && break
        done
        [[ $exclude -eq 0 && -n "$module" ]] && TEMP_MODULES+=("$module")
    done
    SELECTED_MODULES=("${TEMP_MODULES[@]}")
fi

# Add a new function to handle module dependencies
resolve_dependencies() {
    local -a RESOLVED_MODULES=()
    
    for module in "${SELECTED_MODULES[@]}"; do
        RESOLVED_MODULES+=("$module")
        
        # Add dependencies if they're not already selected
        if [[ -n "${MODULE_DEPS[$module]}" ]]; then
            local deps="${MODULE_DEPS[$module]}"
            echo "Module '$module' depends on: $deps"
            
            for dep in $deps; do
                if [[ ! " ${RESOLVED_MODULES[*]} " =~ " ${dep} " ]]; then
                    read -p "Module '$module' depends on '$dep'. Add it? (Y/n) " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                        RESOLVED_MODULES+=("$dep")
                        echo "Added dependency '$dep'"
                    else
                        echo "Warning: Dependency '$dep' not added. This may cause issues."
                    fi
                fi
            done
        fi
    done
    
    SELECTED_MODULES=("${RESOLVED_MODULES[@]}")
}

# Add username prompt
prompt_for_username() {
    if [[ -z "$USER_ONLY" ]]; then
        read -p "Enter your username (will be used in the configuration): " USERNAME
        if [[ -z "$USERNAME" ]]; then
            echo "Username cannot be empty. Using 'nixos' as default."
            USERNAME="nixos"
        fi
        
        read -p "Enter hostname (default: nixos-hyprland): " HOST_NAME
        if [[ -z "$HOST_NAME" ]]; then
            HOST_NAME="nixos-hyprland"
        fi
    else
        # For user-only installation, use current user
        USERNAME="$USER"
    fi
}

# Validate and resolve module dependencies
resolve_dependencies

# Get username for configuration
prompt_for_username

echo "Installing modules: ${SELECTED_MODULES[*]}"

# Download or copy configuration files
if [[ -n "$LOCAL_PATH" ]]; then
    echo "Using local configuration files from $LOCAL_PATH..."
    cp -r "$LOCAL_PATH" "$TEMP_DIR"
else
    echo "Downloading configuration files..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" || {
        echo "Failed to clone repository. Please check your internet connection and the repository URL."
        exit 1
    }
fi

# Validate repository structure
if [[ ! -d "$TEMP_DIR/Nixos" || ! -d "$TEMP_DIR/config" ]]; then
    echo "Error: Invalid repository structure. Missing required directories."
    exit 1
fi

# Install NixOS configuration
if [[ -z "$USER_ONLY" ]]; then
    echo "Installing NixOS configuration..."
    
    # Backup existing configuration
    if [ -f "$NIXOS_CONFIG_DIR/configuration.nix" ]; then
        echo "Backing up existing NixOS configuration..."
        backup_file="$NIXOS_CONFIG_DIR/configuration.nix.backup-$(date +%Y%m%d%H%M%S)"
        cp "$NIXOS_CONFIG_DIR/configuration.nix" "$backup_file"
        echo "Backup saved to: $backup_file"
    fi
    
    # Create modules directory if it doesn't exist
    mkdir -p "$NIXOS_CONFIG_DIR/modules"
    
    # Copy main configuration file
    cp "$TEMP_DIR/Nixos/configuration.nix" "$NIXOS_CONFIG_DIR/"
    
    # Replace username placeholder in configuration files
    find "$TEMP_DIR/Nixos" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
    
    # Replace hostname in flake.nix if using flakes
    if [[ $USE_FLAKES -eq 1 && -f "$TEMP_DIR/Nixos/flake.nix" ]]; then
        sed -i "s/hyprland = nixpkgs.lib.nixosSystem/$HOST_NAME = nixpkgs.lib.nixosSystem/g" "$TEMP_DIR/Nixos/flake.nix"
    fi
    
    # Generate custom imports.nix based on selected modules
    cat > "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOF
{ config, lib, pkgs, ... }:

{
  imports = [
EOF

    # Add selected modules to imports
    for module in "${SELECTED_MODULES[@]}"; do
        if [ -f "$TEMP_DIR/Nixos/modules/$module.nix" ]; then
            echo "    # Including $module module"
            echo "    ./$module.nix" >> "$NIXOS_CONFIG_DIR/modules/imports.nix"
            cp "$TEMP_DIR/Nixos/modules/$module.nix" "$NIXOS_CONFIG_DIR/modules/"
        fi
    done

    cat >> "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOF
  ];
}
EOF

    # Modify configuration.nix to import our generated imports.nix
    sed -i 's|./modules/.*|./modules/imports.nix|g' "$NIXOS_CONFIG_DIR/configuration.nix"
    
    # Remind user to set their username
    echo "Please edit configuration.nix to set your username before rebuilding."
    echo "Example: nano $NIXOS_CONFIG_DIR/configuration.nix"
    
    # Use flakes if requested
    if [[ $USE_FLAKES -eq 1 ]]; then
        if [[ ! -f "$TEMP_DIR/Nixos/flake.nix" ]]; then
            echo "Error: Flakes configuration requested but flake.nix not found."
            exit 1
        fi
        
        # Copy flake files and ensure home-manager directory exists
        echo "Setting up flake configuration..."
        cp "$TEMP_DIR/Nixos/flake.nix" "$NIXOS_CONFIG_DIR/"
        [[ -f "$TEMP_DIR/Nixos/flake.lock" ]] && cp "$TEMP_DIR/Nixos/flake.lock" "$NIXOS_CONFIG_DIR/"
        
        # Copy the home-manager directory for the flake
        if [[ -d "$TEMP_DIR/Nixos/home-manager" ]]; then
            mkdir -p "$NIXOS_CONFIG_DIR/home-manager"
            cp -r "$TEMP_DIR/Nixos/home-manager/"* "$NIXOS_CONFIG_DIR/home-manager/"
        else
            echo "Warning: Could not find home-manager configuration for flakes."
        fi
        
        # Update username and hostname in flake.nix
        sed -i "s/hyprland = nixpkgs.lib.nixosSystem/$HOST_NAME = nixpkgs.lib.nixosSystem/g" "$NIXOS_CONFIG_DIR/flake.nix"
        sed -i "s/username = \"YOUR_USERNAME\"/username = \"$USERNAME\"/g" "$NIXOS_CONFIG_DIR/flake.nix"
        sed -i "s/\"YOUR_USERNAME\"/\"$USERNAME\"/g" "$NIXOS_CONFIG_DIR/flake.nix"
        
        # Rebuild with flakes
        read -p "Proceed with nixos-rebuild using flakes? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Rebuilding NixOS with flakes..."
            nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$HOST_NAME"
        fi
    else
        read -p "Proceed with nixos-rebuild? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Rebuilding NixOS..."
            nixos-rebuild switch
        else
            echo "Skipping rebuild. Please run 'nixos-rebuild switch' manually after making your changes."
        fi
    fi
fi

# For home-manager with flakes (standalone)
if [[ -d "$TEMP_DIR/Nixos/home-manager" && $USE_FLAKES -eq 1 ]]; then
    echo "Setting up standalone home-manager flake..."
    mkdir -p "$HOME/.config/home-manager"
    
    # Copy flake files for standalone home-manager
    cp "$TEMP_DIR/Nixos/flake.nix" "$HOME/.config/home-manager/"
    [[ -f "$TEMP_DIR/Nixos/flake.lock" ]] && cp "$TEMP_DIR/Nixos/flake.lock" "$HOME/.config/home-manager/"
    
    # Copy home-manager configurations
    cp -r "$TEMP_DIR/Nixos/home-manager" "$HOME/.config/"
    
    # Replace username in home-manager configs and flake
    find "$HOME/.config/home-manager" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
    
    echo "You can now use 'home-manager switch --flake ~/.config/home-manager#$USERNAME' to manage your user configuration."
fi

# Install user configurations
echo "Installing user configurations..."

# Install user configs based on selected modules
for module in "${SELECTED_MODULES[@]}"; do
    if [ -d "$TEMP_DIR/config/$module" ]; then
        echo "Installing $module user configuration..."
        mkdir -p "$CONFIG_DIR/$module"
        cp -r "$TEMP_DIR/config/$module/"* "$CONFIG_DIR/$module/"
    fi
done

# Check for home-manager configuration
if [[ -d "$TEMP_DIR/home-manager" ]]; then
    echo "Home-manager configuration found. Installing..."
    
    # Replace username in home-manager configs
    find "$TEMP_DIR/home-manager" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
    
    mkdir -p "$HOME/.config/home-manager"
    cp -r "$TEMP_DIR/home-manager/"* "$HOME/.config/home-manager/"
    
    read -p "Do you want to build the home-manager configuration? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v home-manager &> /dev/null; then
            home-manager switch
        else
            echo "home-manager not found. Please install it first."
        fi
    fi
fi

echo "Installation completed!"
echo "Log out and select Hyprland session to start using your new desktop environment."