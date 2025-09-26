#!/bin/bash

# LatencyFleX Proton uninstallation script
# This script removes all LatencyFleX files and reverts changes

set -e

# Configuration
STEAM_DIR="$HOME/.local/share/Steam"
COMPATDATA_DIR="$STEAM_DIR/steamapps/compatdata"
PROTON_DIR="$STEAM_DIR/steamapps/common/Proton*"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required directories exist
check_dependencies() {
    if [ ! -d "$STEAM_DIR" ]; then
        print_error "Steam directory not found: $STEAM_DIR"
        exit 1
    fi
}

# Find all Proton installations
find_proton_installations() {
    local proton_dirs=($(ls -d $PROTON_DIR 2>/dev/null))
    if [ ${#proton_dirs[@]} -eq 0 ]; then
        print_warning "No Proton installations found"
        return 1
    fi
    echo "${proton_dirs[@]}"
}

# Remove LatencyFleX files from Proton installation
remove_from_proton() {
    local proton_dir="$1"
    local proton_lib_dir="$proton_dir/dist/lib64"
    
    if [ ! -d "$proton_lib_dir" ]; then
        proton_lib_dir="$proton_dir/dist/lib"
        if [ ! -d "$proton_lib_dir" ]; then
            print_warning "Proton lib directory not found in $proton_dir/dist"
            return 1
        fi
    fi
    
    print_status "Removing LatencyFleX from Proton: $proton_dir"
    
    # Files to remove
    local files_to_remove=(
        "$proton_lib_dir/wine/x86_64-unix/latencyflex_layer.so"
        "$proton_lib_dir/wine/x86_64-windows/latencyflex_layer.dll"
        "$proton_lib_dir/wine/x86_64-windows/latencyflex_wine.dll"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [ -f "$file" ]; then
            rm -f "$file"
            print_status "Removed: $file"
        else
            print_warning "File not found: $file"
        fi
    done
}

# Remove DXVK-NVAPI files
remove_dxvk_nvapi() {
    local proton_dir="$1"
    local proton_nvapi_dir="$proton_dir/dist/lib64/wine/nvapi"
    
    if [ ! -d "$proton_nvapi_dir" ]; then
        proton_nvapi_dir="$proton_dir/dist/lib/wine/nvapi"
        if [ ! -d "$proton_nvapi_dir" ]; then
            print_warning "NVAPI directory not found in $proton_dir"
            return 1
        fi
    fi
    
    local nvapi_file="$proton_nvapi_dir/nvapi64.dll"
    
    if [ -f "$nvapi_file" ]; then
        # Check if this is a DXVK-NVAPI file (not the original one)
        if file "$nvapi_file" | grep -q "PE32+"; then
            rm -f "$nvapi_file"
            print_status "Removed DXVK-NVAPI: $nvapi_file"
            
            # Remove directory if empty
            if [ -z "$(ls -A "$proton_nvapi_dir")" ]; then
                rmdir "$proton_nvapi_dir"
                print_status "Removed empty NVAPI directory"
            fi
        else
            print_warning "Not removing $nvapi_file - doesn't appear to be DXVK-NVAPI"
        fi
    else
        print_warning "DXVK-NVAPI file not found: $nvapi_file"
    fi
}

# Remove symlinks from game prefixes
remove_symlinks() {
    local appid="$1"
    
    if [ -n "$appid" ]; then
        # Remove from specific appid
        remove_symlinks_from_prefix "$appid"
    else
        # Remove from all game prefixes
        print_status "Searching for LatencyFleX symlinks in all game prefixes..."
        
        if [ ! -d "$COMPATDATA_DIR" ]; then
            print_warning "compatdata directory not found: $COMPATDATA_DIR"
            return 1
        fi
        
        local found=0
        for prefix_dir in "$COMPATDATA_DIR"/*/pfx; do
            if [ -d "$prefix_dir" ]; then
                local appid=$(basename "$(dirname "$prefix_dir")")
                if remove_symlinks_from_prefix "$appid" "quiet"; then
                    found=1
                fi
            fi
        done
        
        if [ $found -eq 0 ]; then
            print_status "No LatencyFleX symlinks found in any game prefixes"
        fi
    fi
}

# Remove symlinks from a specific game prefix
remove_symlinks_from_prefix() {
    local appid="$1"
    local quiet="$2"
    local prefix_dir="$COMPATDATA_DIR/$appid/pfx"
    
    if [ ! -d "$prefix_dir" ]; then
        [ "$quiet" != "quiet" ] && print_warning "Game prefix not found for appid $appid"
        return 1
    fi
    
    local symlinks=(
        "$prefix_dir/drive_c/windows/system32/latencyflex_layer.dll"
        "$prefix_dir/drive_c/windows/system32/latencyflex_wine.dll"
    )
    
    local found=0
    for symlink in "${symlinks[@]}"; do
        if [ -L "$symlink" ]; then
            # Check if it points to a LatencyFleX file
            if readlink "$symlink" | grep -q "latencyflex"; then
                rm -f "$symlink"
                [ "$quiet" != "quiet" ] && print_status "Removed symlink: $symlink"
                found=1
            fi
        elif [ -f "$symlink" ]; then
            # Check if it's a actual file (not symlink) that might be LatencyFleX
            if file "$symlink" | grep -q "PE32+"; then
                [ "$quiet" != "quiet" ] && print_warning "Found actual file (not symlink): $symlink"
                [ "$quiet" != "quiet" ] && print_warning "This may not be a LatencyFleX file. Skipping."
            fi
        fi
    done
    
    if [ $found -eq 1 ]; then
        [ "$quiet" != "quiet" ] && print_status "Removed all LatencyFleX symlinks for appid $appid"
        return 0
    else
        [ "$quiet" != "quiet" ] && print_status "No LatencyFleX symlinks found for appid $appid"
        return 1
    fi
}

# Remove any leftover LatencyFleX configuration files
remove_config_files() {
    local config_locations=(
        "$HOME/.config/latencyflex"
        "$HOME/.local/share/latencyflex"
        "/tmp/latencyflex"
    )
    
    print_status "Checking for configuration files..."
    
    for location in "${config_locations[@]}"; do
        if [ -d "$location" ]; then
            print_warning "Found configuration directory: $location"
            read -p "Remove this directory? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$location"
                print_status "Removed: $location"
            fi
        fi
    done
}

# Main uninstallation function
main() {
    print_status "Starting LatencyFleX uninstallation..."
    
    check_dependencies
    
    # Find all Proton installations
    local proton_dirs=($(find_proton_installations))
    
    if [ ${#proton_dirs[@]} -gt 0 ]; then
        for proton_dir in "${proton_dirs[@]}"; do
            remove_from_proton "$proton_dir"
            remove_dxvk_nvapi "$proton_dir"
        done
    else
        print_warning "No Proton installations found to clean up"
    fi
    
    # Remove symlinks
    if [ -n "$1" ] && [ "$1" != "--all" ]; then
        remove_symlinks "$1"
    else
        remove_symlinks
    fi
    
    # Optional: remove configuration files
    if [ "$1" = "--all" ]; then
        remove_config_files
    else
        print_status "Skipping configuration files removal (use --all to remove them too)"
    fi
    
    print_status "Uninstallation completed!"
    print_warning "You may need to restart Steam for changes to take effect"
}

# Handle command line arguments
case "$1" in
    --appid)
        if [ -z "$2" ]; then
            print_error "Please provide an AppID"
            exit 1
        fi
        remove_symlinks "$2"
        ;;
    --all)
        main "--all"
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --appid APPID        Remove symlinks only for a specific game AppID"
        echo "  --all                Remove everything including configuration files"
        echo "  --help, -h          Show this help message"
        echo ""
        echo "If no options are provided, the script will remove all LatencyFleX files"
        echo "from Proton installations and game prefixes, but keep config files."
        ;;
    *)
        main
        ;;
esac