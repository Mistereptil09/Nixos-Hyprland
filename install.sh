#!/usr/bin/env bash

set -e

echo "=== NixOS Hyprland Configuration Installer ==="

# Configuration
REPO_URL="https://github.com/yourusername/Nixos-Hyprland.git"
TEMP_DIR="$(mktemp -d)"
NIXOS_CONFIG_DIR="/etc/nixos"
CONFIG_DIR="$HOME/.config"

# Update paths to reflect directory structure
SYSTEM_DIR="nixos"
USER_DIR="home-manager"

# Installation mode
USER_ONLY=0
SYSTEM_ONLY=0
USE_FLAKES=0

# Variables to be populated from module-classification.nix
SYSTEM_MODULES=()
USER_MODULES=()
AVAILABLE_MODULES=()
declare -A MODULE_DEPS

cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Define the load_module_classification function early to use it for help and validation
load_module_classification() {
    echo "Loading module classification..."
    local classification_file="$TEMP_DIR/$SYSTEM_DIR/module-classification.nix"
    
    if [ ! -f "$classification_file" ]; then
        echo "Error: Module classification file not found at $classification_file"
        echo "Cannot continue without module definitions."
        exit 1
    fi
    
    # Extract module lists - using grep and awk for robust parsing
    echo "  - Reading available modules..."
    AVAILABLE_MODULES=($(grep -A50 "all = \[" "$classification_file" | grep -B50 "\];" | grep "\"" | awk -F'"' '{print $2}' | grep -v '^$'))
    
    echo "  - Reading system modules..."
    SYSTEM_MODULES=($(grep -A50 "system = \[" "$classification_file" | grep -B50 "\];" | grep "\"" | awk -F'"' '{print $2}' | grep -v '^$'))
    
    echo "  - Reading user modules..."
    USER_MODULES=($(grep -A50 "user = \[" "$classification_file" | grep -B50 "\];" | grep "\"" | awk -F'"' '{print $2}' | grep -v '^$'))
    
    echo "  - Reading module dependencies..."
    # Parse dependencies section - more complex as it's nested
    local in_deps=0
    local current_module=""
    
    while IFS= read -r line; do
        if [[ "$line" == *"dependencies = {"* ]]; then
            in_deps=1
            continue
        fi
        
        if [[ $in_deps -eq 1 ]]; then
            if [[ "$line" == *"};"* ]]; then
                in_deps=0
                continue
            fi
            
            # Extract module name
            if [[ "$line" =~ \"([^\"]+)\"[[:space:]]*=[[:space:]]*\[ ]]; then
                current_module="${BASH_REMATCH[1]}"
                continue
            fi
            
            # Extract dependencies for current module
            if [[ "$line" =~ \"([^\"]+)\" && -n "$current_module" ]]; then
                dep_module="${BASH_REMATCH[1]}"
                if [[ -z "${MODULE_DEPS[$current_module]}" ]]; then
                    MODULE_DEPS[$current_module]="$dep_module"
                else
                    MODULE_DEPS[$current_module]="${MODULE_DEPS[$current_module]} $dep_module"
                fi
            fi
        fi
    done < "$classification_file"
    
    # Log what we found
    echo "Found ${#AVAILABLE_MODULES[@]} available modules"
    echo "Found ${#SYSTEM_MODULES[@]} system modules"
    echo "Found ${#USER_MODULES[@]} user modules"
    echo "Found ${#MODULE_DEPS[@]} module dependency relationships"
}

# Download or copy configuration files early to access the module classification
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

# Load module information right away so we can use it for help and validation
load_module_classification

# Now we can initialize the selected modules after knowing what's available
SELECTED_MODULES=(${AVAILABLE_MODULES[@]})
ONLY_MODULES=()
EXCLUDE_MODULES=()

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --user-only                Install only user configurations via home-manager"
    echo "  --system-only              Install only system configurations (requires sudo)"
    echo "  --only MODULE1,MODULE2     Only install specified modules (comma-separated)"
    echo "  --exclude MODULE1,MODULE2  Exclude specified modules (comma-separated)"
    echo "  --list-modules             List available modules"
    echo "  --flakes                   Use flakes-based configuration"
    echo "  --local PATH               Use local files instead of cloning repository"
    echo "  --help                     Show this help message"
    echo ""
    echo "Installation Modes:"
    echo "  default                    Install both system and user configurations"
    echo "  --user-only                Install only home-manager configurations"
    echo "  --system-only              Install only system configurations"
    echo ""
    echo "Available Modules:"
    echo "  System Modules:"
    for module in "${SYSTEM_MODULES[@]}"; do
        echo "    - $module"
    done
    echo ""
    echo "  User Modules:"
    for module in "${USER_MODULES[@]}"; do
        echo "    - $module"
    done
    
    echo ""
    echo "Examples:"
    echo "  $0 --only desktop-system,apps          # Install specific modules"
    echo "  $0 --exclude gaming-system,gaming-user # Install all except gaming modules"
    echo "  $0 --system-only --only desktop-system # Install only desktop at system level"
    echo "  $0 --user-only --only desktop-user,dev # Install only desktop and dev at user level"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --user-only)
            USER_ONLY=1
            shift
            ;;
        --system-only)
            SYSTEM_ONLY=1
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
            echo "  System Modules (installed to /etc/nixos):"
            for module in "${SYSTEM_MODULES[@]}"; do
                echo "    - $module"
                if [[ -n "${MODULE_DEPS[$module]}" ]]; then
                    echo "      Dependencies: ${MODULE_DEPS[$module]}"
                fi
            done
            echo ""
            echo "  User Modules (installed via home-manager):"
            for module in "${USER_MODULES[@]}"; do
                echo "    - $module"
                if [[ -n "${MODULE_DEPS[$module]}" ]]; then
                    echo "      Dependencies: ${MODULE_DEPS[$module]}"
                fi
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

# Check for conflicting options
if [[ $USER_ONLY -eq 1 && $SYSTEM_ONLY -eq 1 ]]; then
    echo "Error: --user-only and --system-only cannot be used together."
    echo "Please choose only one installation mode."
    exit 1
fi

# Check if running as root for NixOS config changes
if [[ $EUID -ne 0 && $USER_ONLY -eq 0 ]]; then
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

# Add a function to handle module dependencies
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
    if [[ $USER_ONLY -eq 0 ]]; then
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

# Install NixOS configuration
if [[ $USER_ONLY -eq 0 ]]; then
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
    cp "$TEMP_DIR/$SYSTEM_DIR/configuration.nix" "$NIXOS_CONFIG_DIR/"
    
    # Replace username placeholder in configuration files
    find "$TEMP_DIR/$SYSTEM_DIR" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
    
    # Replace hostname in flake.nix if using flakes
    if [[ $USE_FLAKES -eq 1 && -f "$TEMP_DIR/$SYSTEM_DIR/flake.nix" ]]; then
        sed -i "s/hyprland = nixpkgs.lib.nixosSystem/$HOST_NAME = nixpkgs.lib.nixosSystem/g" "$TEMP_DIR/$SYSTEM_DIR/flake.nix"
    fi
    
    # Generate custom imports.nix for the system level based on selected modules
    echo "Generating system-level imports..."
    cat > "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOF
{ config, lib, pkgs, ... }:

{
  imports = [
EOF

    # Add selected system-level modules to imports
    for module in "${SELECTED_MODULES[@]}"; do
        # Check if this module should be included at system level
        if [[ " ${SYSTEM_MODULES[*]} " =~ " ${module} " || " ${MIXED_MODULES[*]} " =~ " ${module} " ]]; then
            if [ -f "$TEMP_DIR/$SYSTEM_DIR/modules/$module.nix" ]; then
                echo "    # Including system module: $module"
                echo "    ./$module.nix" >> "$NIXOS_CONFIG_DIR/modules/imports.nix"
                cp "$TEMP_DIR/$SYSTEM_DIR/modules/$module.nix" "$NIXOS_CONFIG_DIR/modules/"
            fi
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
        if [[ ! -f "$TEMP_DIR/$SYSTEM_DIR/flake.nix" ]]; then
            echo "Error: Flakes configuration requested but flake.nix not found."
            exit 1
        fi
        
        # Copy flake files and ensure home-manager directory exists
        echo "Setting up flake configuration..."
        cp "$TEMP_DIR/$SYSTEM_DIR/flake.nix" "$NIXOS_CONFIG_DIR/"
        [[ -f "$TEMP_DIR/$SYSTEM_DIR/flake.lock" ]] && cp "$TEMP_DIR/$SYSTEM_DIR/flake.lock" "$NIXOS_CONFIG_DIR/"
        
        # Copy the home-manager directory for the flake
        if [[ -d "$TEMP_DIR/$SYSTEM_DIR/home-manager" ]]; then
            mkdir -p "$NIXOS_CONFIG_DIR/home-manager"
            cp -r "$TEMP_DIR/$SYSTEM_DIR/home-manager/"* "$NIXOS_CONFIG_DIR/home-manager/"
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

# Install home-manager configuration with proper imports
if [[ $SYSTEM_ONLY -eq 0 && -d "$TEMP_DIR/$USER_DIR" ]]; then
    echo "Setting up home-manager configuration..."
    mkdir -p "$HOME/.config/home-manager/modules"
    
    # Copy base home-manager configuration files
    cp "$TEMP_DIR/$USER_DIR/home.nix" "$HOME/.config/home-manager/"
    
    # Generate imports.nix for home-manager based on selected modules
    echo "Generating user-level imports..."
    cat > "$HOME/.config/home-manager/modules/imports.nix" << EOF
{ config, lib, pkgs, ... }:

{
  imports = [
EOF

    # Add selected user-level modules to imports - Fix for app vs apps inconsistency
    for module in "${SELECTED_MODULES[@]}"; do
        # Check if this module should be included at user level
        if [[ " ${USER_MODULES[*]} " =~ " ${module} " || " ${MIXED_MODULES[*]} " =~ " ${module} " ]]; then
            # Check first for exact module name
            if [ -f "$TEMP_DIR/$USER_DIR/modules/$module.nix" ]; then
                echo "    # Including user module: $module"
                echo "    ./$module.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
                cp "$TEMP_DIR/$USER_DIR/modules/$module.nix" "$HOME/.config/home-manager/modules/"
            # Then check for plural version (app vs apps)
            elif [ -f "$TEMP_DIR/$USER_DIR/modules/${module}s.nix" ]; then
                echo "    # Including user module: ${module}s"
                echo "    ./${module}s.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
                cp "$TEMP_DIR/$USER_DIR/modules/${module}s.nix" "$HOME/.config/home-manager/modules/"
            fi
        fi
    done

    # Copy utils module if it exists - since it's common on both sides
    if [ -f "$TEMP_DIR/$USER_DIR/modules/utils.nix" ]; then
        if ! grep -q "./utils.nix" "$HOME/.config/home-manager/modules/imports.nix"; then
            echo "    # Including utilities module"
            echo "    ./utils.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
            cp "$TEMP_DIR/$USER_DIR/modules/utils.nix" "$HOME/.config/home-manager/modules/"
        fi
    fi

    cat >> "$HOME/.config/home-manager/modules/imports.nix" << EOF
  ];
}
EOF

    # Replace username in home-manager configs
    find "$HOME/.config/home-manager" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
    
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

# For home-manager with flakes (standalone)
if [[ -d "$TEMP_DIR/$USER_DIR" && $USE_FLAKES -eq 1 ]]; then
    echo "Setting up standalone home-manager flake..."
    mkdir -p "$HOME/.config/home-manager"
    
    # Copy flake files for standalone home-manager
    cp "$TEMP_DIR/$SYSTEM_DIR/flake.nix" "$HOME/.config/home-manager/"
    [[ -f "$TEMP_DIR/$SYSTEM_DIR/flake.lock" ]] && cp "$TEMP_DIR/flake.lock" "$HOME/.config/home-manager/"
    
    # Copy home-manager configurations
    cp -r "$TEMP_DIR/$USER_DIR" "$HOME/.config/"
    
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

# Display installation summary
echo "=== Installation Summary ==="
if [[ $USER_ONLY -eq 1 ]]; then
    echo "Mode: User-only (home-manager)"
elif [[ $SYSTEM_ONLY -eq 1 ]]; then
    echo "Mode: System-only (NixOS)"
else
    echo "Mode: Complete (system and user)"
fi
echo "Installed modules: ${SELECTED_MODULES[*]}"
echo "Installation completed!"

if [[ $SYSTEM_ONLY -eq 0 ]]; then
    echo "To apply home-manager changes: home-manager switch"
fi
if [[ $USER_ONLY -eq 0 ]]; then
    echo "Log out and select Hyprland session to start using your new desktop environment."
fi