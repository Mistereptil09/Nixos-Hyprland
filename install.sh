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
if [[ -n "$LOCAL_PATH" ]]; thenn files early to access the module classification
    echo "Using local configuration files from $LOCAL_PATH..."
    cp -r "$LOCAL_PATH" "$TEMP_DIR" files from $LOCAL_PATH..."
elsecp -r "$LOCAL_PATH" "$TEMP_DIR"
    echo "Downloading configuration files..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR" || {
        echo "Failed to clone repository. Please check your internet connection and the repository URL."
        exit 1pth 1 for a shallow clone to reduce traffic and avoid rate limits
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$REPO_URL" "$TEMP_DIR" || {
        echo "Failed to clone repository without authentication."
        echo "Possible solutions:"
        echo "  1. Make sure the repository is public"
        echo "  2. Use --local option with a local copy of the repository"
        echo "  3. Run: git config --global credential.helper store # (to save credentials)"
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
    echo "  --system-only              Install only system configurations (requires sudo)" --download METHOD          Download method: git (default), curl, or wget"
    echo "  --only MODULE1,MODULE2     Only install specified modules (comma-separated)"
    echo "  --exclude MODULE1,MODULE2  Exclude specified modules (comma-separated)"
    echo "  --list-modules             List available modules"ns"
    echo "  --flakes                   Use flakes-based configuration"tions"
    echo "  --local PATH               Use local files instead of cloning repository" --system-only              Install only system configurations"
    echo "  --help                     Show this help message"
    echo """
    echo "Installation Modes:"
    echo "  default                    Install both system and user configurations"MODULES[@]}"; do
    echo "  --user-only                Install only home-manager configurations"echo "    - $module"
    echo "  --system-only              Install only system configurations"
    echo ""
    echo "Available Modules:"
    echo "  System Modules:"DULES[@]}"; do
    for module in "${SYSTEM_MODULES[@]}"; doecho "    - $module"
        echo "    - $module"done
    done
    echo ""
    echo "  User Modules:"
    for module in "${USER_MODULES[@]}"; do
        echo "    - $module"
    done
       echo "  $0 --user-only --only desktop-user,dev # Install only desktop and dev at user level"
    echo ""    echo "  $0 --download curl                     # Use curl instead of git to avoid login prompt"
    echo "Examples:"
    echo "  $0 --only desktop-system,apps          # Install specific modules"
    echo "  $0 --exclude gaming-system,gaming-user # Install all except gaming modules"line arguments
    echo "  $0 --system-only --only desktop-system # Install only desktop at system level"; do
    echo "  $0 --user-only --only desktop-user,dev # Install only desktop and dev at user level"
        --user-only)
            USER_ONLY=1
            shiftrguments
            ;;
        --system-only)
            SYSTEM_ONLY=1-only)
            shiftR_ONLY=1
            ;;
        --only)
            IFS=',' read -ra ONLY_MODULES <<< "$2"ly)
            SELECTED_MODULES=("${ONLY_MODULES[@]}")STEM_ONLY=1
            shift 2
            ;;
        --exclude)
            IFS=',' read -ra EXCLUDE_MODULES <<< "$2"
            # Filter out excluded modules
            for module in "${EXCLUDE_MODULES[@]}"; dot 2
                SELECTED_MODULES=("${SELECTED_MODULES[@]/$module/}")
            done
            # Clean up empty elements read -ra EXCLUDE_MODULES <<< "$2"
            SELECTED_MODULES=("${SELECTED_MODULES[@]}")Filter out excluded modules
            shift 2in "${EXCLUDE_MODULES[@]}"; do
            ;;SELECTED_MODULES[@]/$module/}")
        --list-modules)
            echo "Available modules:"
            echo "  System Modules (installed to /etc/nixos):"ECTED_MODULES[@]}")
            for module in "${SYSTEM_MODULES[@]}"; do
                echo "    - $module"
                if [[ -n "${MODULE_DEPS[$module]}" ]]; thenules)
                    echo "      Dependencies: ${MODULE_DEPS[$module]}" "Available modules:"
                fi System Modules (installed to /etc/nixos):"
            done
            echo ""
            echo "  User Modules (installed via home-manager):"EPS[$module]}" ]]; then
            for module in "${USER_MODULES[@]}"; do[$module]}"
                echo "    - $module"
                if [[ -n "${MODULE_DEPS[$module]}" ]]; then
                    echo "      Dependencies: ${MODULE_DEPS[$module]}" ""
                fi  User Modules (installed via home-manager):"
            doner module in "${USER_MODULES[@]}"; do
            exit 0cho "    - $module"
            ;; "${MODULE_DEPS[$module]}" ]]; then
        --flakes)   echo "      Dependencies: ${MODULE_DEPS[$module]}"
            USE_FLAKES=1  fi
            shift
            ;;
        --local)
            LOCAL_PATH="$2"es)
            shift 2_FLAKES=1
            ;;
        --help)
            show_helpl)
            exit 0  LOCAL_PATH="$2"
            ;;
        *)
            echo "Unknown option: $1"
            show_helpow_help
            exit 1    exit 0
            ;;        ;;
    esac        --download)
done"

# Check for conflicting options
if [[ $USER_ONLY -eq 1 && $SYSTEM_ONLY -eq 1 ]]; then
    echo "Error: --user-only and --system-only cannot be used together."  echo "Unknown option: $1"
    echo "Please choose only one installation mode."          show_help
    exit 1            exit 1
fi

# Check if running as root for NixOS config changes
if [[ $EUID -ne 0 && $USER_ONLY -eq 0 ]]; then
    echo "This script needs to be run as root to modify system configuration."r conflicting options
if [[ $USER_ONLY -eq 1 && $SYSTEM_ONLY -eq 1 ]]; then  echo "Run with --user-only to only install user configurations."
    echo "Error: --user-only and --system-only cannot be used together."    exit 1
    echo "Please choose only one installation mode."
    exit 1
fi

# Check if running as root for NixOS config changes&& -n "$module" ]]; then
if [[ $EUID -ne 0 && $USER_ONLY -eq 0 ]]; thenError: Unknown module '$module'"
    echo "This script needs to be run as root to modify system configuration."  echo "Available modules: ${AVAILABLE_MODULES[*]}"
    echo "Run with --user-only to only install user configurations."    exit 1
    exit 1    fi
fi

# Validate selected modulesion to properly filter the array
for module in "${SELECTED_MODULES[@]}"; do
    if [[ ! " ${AVAILABLE_MODULES[*]} " =~ " ${module} " && -n "$module" ]]; then()
        echo "Error: Unknown module '$module'"
        echo "Available modules: ${AVAILABLE_MODULES[*]}"
        exit 1ex_module in "${EXCLUDE_MODULES[@]}"; do
    fi
donedone
] && TEMP_MODULES+=("$module")
# Fix module exclusion to properly filter the array  done
if [[ ${#EXCLUDE_MODULES[@]} -gt 0 ]]; then    SELECTED_MODULES=("${TEMP_MODULES[@]}")
    TEMP_MODULES=()
    for module in "${SELECTED_MODULES[@]}"; do
        exclude=0e dependencies
        for ex_module in "${EXCLUDE_MODULES[@]}"; dolve_dependencies() {
            [[ "$module" == "$ex_module" ]] && exclude=1 && break
        done
        [[ $exclude -eq 0 && -n "$module" ]] && TEMP_MODULES+=("$module")module in "${SELECTED_MODULES[@]}"; do
    done
    SELECTED_MODULES=("${TEMP_MODULES[@]}")
fiy selected

# Add a function to handle module dependencieslocal deps="${MODULE_DEPS[$module]}"
resolve_dependencies() {e' depends on: $deps"
    local -a RESOLVED_MODULES=()
    
    for module in "${SELECTED_MODULES[@]}"; do" ${RESOLVED_MODULES[*]} " =~ " ${dep} " ]]; then
        RESOLVED_MODULES+=("$module")t? (Y/n) " -n 1 -r
        
        # Add dependencies if they're not already selected $REPLY ]]; then
        if [[ -n "${MODULE_DEPS[$module]}" ]]; thenRESOLVED_MODULES+=("$dep")
            local deps="${MODULE_DEPS[$module]}"
            echo "Module '$module' depends on: $deps"se
                  echo "Warning: Dependency '$dep' not added. This may cause issues."
            for dep in $deps; do    fi
                if [[ ! " ${RESOLVED_MODULES[*]} " =~ " ${dep} " ]]; then      fi
                    read -p "Module '$module' depends on '$dep'. Add it? (Y/n) " -n 1 -r    done
                    echo    fi
                    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
                        RESOLVED_MODULES+=("$dep")   
                        echo "Added dependency '$dep'"    SELECTED_MODULES=("${RESOLVED_MODULES[@]}")
                    else
                        echo "Warning: Dependency '$dep' not added. This may cause issues."
                    fi
                fi
            done
        fin): " USERNAME
    done ]]; then
      echo "Username cannot be empty. Using 'nixos' as default."
    SELECTED_MODULES=("${RESOLVED_MODULES[@]}")    USERNAME="nixos"
}

# Add username promptlt: nixos-hyprland): " HOST_NAME
prompt_for_username() { [[ -z "$HOST_NAME" ]]; then
    if [[ $USER_ONLY -eq 0 ]]; then    HOST_NAME="nixos-hyprland"
        read -p "Enter your username (will be used in the configuration): " USERNAME
        if [[ -z "$USERNAME" ]]; then
            echo "Username cannot be empty. Using 'nixos' as default."  # For user-only installation, use current user
            USERNAME="nixos"       USERNAME="$USER"
        fi    fi
        
        read -p "Enter hostname (default: nixos-hyprland): " HOST_NAME
        if [[ -z "$HOST_NAME" ]]; then# Validate and resolve module dependencies
            HOST_NAME="nixos-hyprland"
        fi
    else# Get username for configuration
        # For user-only installation, use current user
        USERNAME="$USER"
    fiELECTED_MODULES[*]}"
}

# Validate and resolve module dependencies[ $USER_ONLY -eq 0 ]]; then
resolve_dependenciesation..."

# Get username for configuration
prompt_for_username

echo "Installing modules: ${SELECTED_MODULES[*]}"guration.nix.backup-$(date +%Y%m%d%H%M%S)"
  cp "$NIXOS_CONFIG_DIR/configuration.nix" "$backup_file"
# Install NixOS configuration    echo "Backup saved to: $backup_file"
if [[ $USER_ONLY -eq 0 ]]; then
    echo "Installing NixOS configuration..."
    # Create modules directory if it doesn't exist
    # Backup existing configurationdules"
    if [ -f "$NIXOS_CONFIG_DIR/configuration.nix" ]; then
        echo "Backing up existing NixOS configuration..."# Copy main configuration file
        backup_file="$NIXOS_CONFIG_DIR/configuration.nix.backup-$(date +%Y%m%d%H%M%S)"CONFIG_DIR/"
        cp "$NIXOS_CONFIG_DIR/configuration.nix" "$backup_file"
        echo "Backup saved to: $backup_file"# Replace username placeholder in configuration files
    fiix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
    
    # Create modules directory if it doesn't exist
    mkdir -p "$NIXOS_CONFIG_DIR/modules" [[ $USE_FLAKES -eq 1 && -f "$TEMP_DIR/$SYSTEM_DIR/flake.nix" ]]; then
        sed -i "s/hyprland = nixpkgs.lib.nixosSystem/$HOST_NAME = nixpkgs.lib.nixosSystem/g" "$TEMP_DIR/$SYSTEM_DIR/flake.nix"
    # Copy main configuration file
    cp "$TEMP_DIR/$SYSTEM_DIR/configuration.nix" "$NIXOS_CONFIG_DIR/"
    ased on selected modules
    # Replace username placeholder in configuration files-level imports..."
    find "$TEMP_DIR/$SYSTEM_DIR" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;    cat > "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOF
     config, lib, pkgs, ... }:
    # Replace hostname in flake.nix if using flakes
    if [[ $USE_FLAKES -eq 1 && -f "$TEMP_DIR/$SYSTEM_DIR/flake.nix" ]]; then
        sed -i "s/hyprland = nixpkgs.lib.nixosSystem/$HOST_NAME = nixpkgs.lib.nixosSystem/g" "$TEMP_DIR/$SYSTEM_DIR/flake.nix"  imports = [
    fi
    
    # Generate custom imports.nix for the system level based on selected modules
    echo "Generating system-level imports..."
    cat > "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOF
{ config, lib, pkgs, ... }:${MIXED_MODULES[*]} " =~ " ${module} " ]]; then

{
  imports = [  echo "    ./$module.nix" >> "$NIXOS_CONFIG_DIR/modules/imports.nix"
EOF      cp "$TEMP_DIR/$SYSTEM_DIR/modules/$module.nix" "$NIXOS_CONFIG_DIR/modules/"
    fi
    # Add selected system-level modules to imports        fi
    for module in "${SELECTED_MODULES[@]}"; do
        # Check if this module should be included at system level
        if [[ " ${SYSTEM_MODULES[*]} " =~ " ${module} " || " ${MIXED_MODULES[*]} " =~ " ${module} " ]]; then   cat >> "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOF
            if [ -f "$TEMP_DIR/$SYSTEM_DIR/modules/$module.nix" ]; then;
                echo "    # Including system module: $module"}
                echo "    ./$module.nix" >> "$NIXOS_CONFIG_DIR/modules/imports.nix"
                cp "$TEMP_DIR/$SYSTEM_DIR/modules/$module.nix" "$NIXOS_CONFIG_DIR/modules/"
            fi# Modify configuration.nix to import our generated imports.nix
        fiports.nix|g' "$NIXOS_CONFIG_DIR/configuration.nix"
    done

    cat >> "$NIXOS_CONFIG_DIR/modules/imports.nix" << EOFecho "Please edit configuration.nix to set your username before rebuilding."
  ];S_CONFIG_DIR/configuration.nix"
}
EOF

    # Modify configuration.nix to import our generated imports.nix "$TEMP_DIR/$SYSTEM_DIR/flake.nix" ]]; then
    sed -i 's|./modules/.*|./modules/imports.nix|g' "$NIXOS_CONFIG_DIR/configuration.nix"  echo "Error: Flakes configuration requested but flake.nix not found."
        exit 1
    # Remind user to set their username
    echo "Please edit configuration.nix to set your username before rebuilding."
    echo "Example: nano $NIXOS_CONFIG_DIR/configuration.nix"ts
    
    # Use flakes if requestedcp "$TEMP_DIR/$SYSTEM_DIR/flake.nix" "$NIXOS_CONFIG_DIR/"
    if [[ $USE_FLAKES -eq 1 ]]; thencp "$TEMP_DIR/$SYSTEM_DIR/flake.lock" "$NIXOS_CONFIG_DIR/"
        if [[ ! -f "$TEMP_DIR/$SYSTEM_DIR/flake.nix" ]]; then
            echo "Error: Flakes configuration requested but flake.nix not found."ke
            exit 1
        fimkdir -p "$NIXOS_CONFIG_DIR/home-manager"
        manager/"
        # Copy flake files and ensure home-manager directory existsse
        echo "Setting up flake configuration..."    echo "Warning: Could not find home-manager configuration for flakes."
        cp "$TEMP_DIR/$SYSTEM_DIR/flake.nix" "$NIXOS_CONFIG_DIR/"
        [[ -f "$TEMP_DIR/$SYSTEM_DIR/flake.lock" ]] && cp "$TEMP_DIR/$SYSTEM_DIR/flake.lock" "$NIXOS_CONFIG_DIR/"
        
        # Copy the home-manager directory for the flakesSystem/g" "$NIXOS_CONFIG_DIR/flake.nix"
        if [[ -d "$TEMP_DIR/$SYSTEM_DIR/home-manager" ]]; thensed -i "s/username = \"YOUR_USERNAME\"/username = \"$USERNAME\"/g" "$NIXOS_CONFIG_DIR/flake.nix"
            mkdir -p "$NIXOS_CONFIG_DIR/home-manager"NAME\"/\"$USERNAME\"/g" "$NIXOS_CONFIG_DIR/flake.nix"
            cp -r "$TEMP_DIR/$SYSTEM_DIR/home-manager/"* "$NIXOS_CONFIG_DIR/home-manager/"
        elsebuild with flakes
            echo "Warning: Could not find home-manager configuration for flakes."uild using flakes? (y/n) " -n 1 -r
        fi
        
        # Update username and hostname in flake.nix  echo "Rebuilding NixOS with flakes..."
        sed -i "s/hyprland = nixpkgs.lib.nixosSystem/$HOST_NAME = nixpkgs.lib.nixosSystem/g" "$NIXOS_CONFIG_DIR/flake.nix"    nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$HOST_NAME"
        sed -i "s/username = \"YOUR_USERNAME\"/username = \"$USERNAME\"/g" "$NIXOS_CONFIG_DIR/flake.nix"
        sed -i "s/\"YOUR_USERNAME\"/\"$USERNAME\"/g" "$NIXOS_CONFIG_DIR/flake.nix"
        uild? (y/n) " -n 1 -r
        # Rebuild with flakes
        read -p "Proceed with nixos-rebuild using flakes? (y/n) " -n 1 -r]; then
        echoecho "Rebuilding NixOS..."
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Rebuilding NixOS with flakes..."se
            nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$HOST_NAME"      echo "Skipping rebuild. Please run 'nixos-rebuild switch' manually after making your changes."
        fi      fi
    else    fi
        read -p "Proceed with nixos-rebuild? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; thenports
            echo "Rebuilding NixOS..."IR" ]]; then
            nixos-rebuild switchecho "Setting up home-manager configuration..."
        else"
            echo "Skipping rebuild. Please run 'nixos-rebuild switch' manually after making your changes."
        fi# Copy base home-manager configuration files
    fi
fi
ules
# Install home-manager configuration with proper importsevel imports..."
if [[ $SYSTEM_ONLY -eq 0 && -d "$TEMP_DIR/$USER_DIR" ]]; then    cat > "$HOME/.config/home-manager/modules/imports.nix" << EOF
    echo "Setting up home-manager configuration..." config, lib, pkgs, ... }:
    mkdir -p "$HOME/.config/home-manager/modules"
    
    # Copy base home-manager configuration files  imports = [
    cp "$TEMP_DIR/$USER_DIR/home.nix" "$HOME/.config/home-manager/"
    
    # Generate imports.nix for home-manager based on selected modulesvs apps inconsistency
    echo "Generating user-level imports..."
    cat > "$HOME/.config/home-manager/modules/imports.nix" << EOFed at user level
{ config, lib, pkgs, ... }:DULES[*]} " =~ " ${module} " ]]; then

{
  imports = [
EOFg/home-manager/modules/imports.nix"
g/home-manager/modules/"
    # Add selected user-level modules to imports - Fix for app vs apps inconsistency
    for module in "${SELECTED_MODULES[@]}"; do
        # Check if this module should be included at user level
        if [[ " ${USER_MODULES[*]} " =~ " ${module} " || " ${MIXED_MODULES[*]} " =~ " ${module} " ]]; then  echo "    ./${module}s.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
            # Check first for exact module name      cp "$TEMP_DIR/$USER_DIR/modules/${module}s.nix" "$HOME/.config/home-manager/modules/"
            if [ -f "$TEMP_DIR/$USER_DIR/modules/$module.nix" ]; then    fi
                echo "    # Including user module: $module"        fi
                echo "    ./$module.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
                cp "$TEMP_DIR/$USER_DIR/modules/$module.nix" "$HOME/.config/home-manager/modules/"
            # Then check for plural version (app vs apps)
            elif [ -f "$TEMP_DIR/$USER_DIR/modules/${module}s.nix" ]; then ]; then
                echo "    # Including user module: ${module}s"hen
                echo "    ./${module}s.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
                cp "$TEMP_DIR/$USER_DIR/modules/${module}s.nix" "$HOME/.config/home-manager/modules/"  echo "    ./utils.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
            fi      cp "$TEMP_DIR/$USER_DIR/modules/utils.nix" "$HOME/.config/home-manager/modules/"
        fi        fi
    done

    # Copy utils module if it exists - since it's common on both sides   cat >> "$HOME/.config/home-manager/modules/imports.nix" << EOF
    if [ -f "$TEMP_DIR/$USER_DIR/modules/utils.nix" ]; then;
        if ! grep -q "./utils.nix" "$HOME/.config/home-manager/modules/imports.nix"; then}
            echo "    # Including utilities module"
            echo "    ./utils.nix" >> "$HOME/.config/home-manager/modules/imports.nix"
            cp "$TEMP_DIR/$USER_DIR/modules/utils.nix" "$HOME/.config/home-manager/modules/"# Replace username in home-manager configs
        fiUSERNAME/$USERNAME/g" {} \;
    fi
he home-manager configuration? (y/n) " -n 1 -r
    cat >> "$HOME/.config/home-manager/modules/imports.nix" << EOF
  ];then
}ommand -v home-manager &> /dev/null; then
EOF
se
    # Replace username in home-manager configs      echo "home-manager not found. Please install it first."
    find "$HOME/.config/home-manager" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;      fi
        fi
    read -p "Do you want to build the home-manager configuration? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v home-manager &> /dev/null; thenAKES -eq 1 ]]; then
            home-manager switchecho "Setting up standalone home-manager flake..."
        else
            echo "home-manager not found. Please install it first."
        fi
    ficp "$TEMP_DIR/$SYSTEM_DIR/flake.nix" "$HOME/.config/home-manager/"
fi.lock" ]] && cp "$TEMP_DIR/flake.lock" "$HOME/.config/home-manager/"

# For home-manager with flakes (standalone)# Copy home-manager configurations
if [[ -d "$TEMP_DIR/$USER_DIR" && $USE_FLAKES -eq 1 ]]; then
    echo "Setting up standalone home-manager flake..."
    mkdir -p "$HOME/.config/home-manager"# Replace username in home-manager configs and flake
    
    # Copy flake files for standalone home-manager  
    cp "$TEMP_DIR/$SYSTEM_DIR/flake.nix" "$HOME/.config/home-manager/"    echo "You can now use 'home-manager switch --flake ~/.config/home-manager#$USERNAME' to manage your user configuration."
    [[ -f "$TEMP_DIR/$SYSTEM_DIR/flake.lock" ]] && cp "$TEMP_DIR/flake.lock" "$HOME/.config/home-manager/"
    
    # Copy home-manager configurations# Install user configurations
    cp -r "$TEMP_DIR/$USER_DIR" "$HOME/.config/"
    
    # Replace username in home-manager configs and flakees
    find "$HOME/.config/home-manager" -type f -name "*.nix" -exec sed -i "s/YOUR_USERNAME/$USERNAME/g" {} \;
     ]; then
    echo "You can now use 'home-manager switch --flake ~/.config/home-manager#$USERNAME' to manage your user configuration."
fi  mkdir -p "$CONFIG_DIR/$module"
    cp -r "$TEMP_DIR/config/$module/"* "$CONFIG_DIR/$module/"
# Install user configurations    fi
echo "Installing user configurations..."

# Install user configs based on selected modules
for module in "${SELECTED_MODULES[@]}"; do
    if [ -d "$TEMP_DIR/config/$module" ]; then
        echo "Installing $module user configuration..."ger)"
        mkdir -p "$CONFIG_DIR/$module" [[ $SYSTEM_ONLY -eq 1 ]]; then
        cp -r "$TEMP_DIR/config/$module/"* "$CONFIG_DIR/$module/"
    fise
done

# Display installation summaryecho "Installed modules: ${SELECTED_MODULES[*]}"
echo "=== Installation Summary ==="
if [[ $USER_ONLY -eq 1 ]]; then
    echo "Mode: User-only (home-manager)" [[ $SYSTEM_ONLY -eq 0 ]]; then
elif [[ $SYSTEM_ONLY -eq 1 ]]; then changes: home-manager switch"
    echo "Mode: System-only (NixOS)"
else [[ $USER_ONLY -eq 0 ]]; then











fi    echo "Log out and select Hyprland session to start using your new desktop environment."if [[ $USER_ONLY -eq 0 ]]; thenfi    echo "To apply home-manager changes: home-manager switch"if [[ $SYSTEM_ONLY -eq 0 ]]; thenecho "Installation completed!"echo "Installed modules: ${SELECTED_MODULES[*]}"fi    echo "Mode: Complete (system and user)"    echo "Log out and select Hyprland session to start using your new desktop environment."
fi