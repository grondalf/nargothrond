#!/bin/bash

# LatencyFleX Proton installation script
# This script installs LatencyFleX extensions for Proton-based games

set -e

# Configuration
LATENCYFLEX_VERSION="2.2.0"  # Update this to the desired version
STEAM_DIR="$HOME/.local/share/Steam"
COMPATDATA_DIR="$STEAM_DIR/steamapps/compatdata"
PROTON_DIR="$STEAM_DIR/steamapps/common/Proton*"  # Will use the latest Proton

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
    
    if [ ! -d "$COMPATDATA_DIR" ]; then
        print_warning "compatdata directory not found, creating..."
        mkdir -p "$COMPATDATA_DIR"
    fi
}

# Download LatencyFleX release artifacts
download_latencyflex() {
    local download_url="https://github.com/ishitatsuyuki/LatencyFleX/releases/download/v${LATENCYFLEX_VERSION}/latencyflex-wine-v${LATENCYFLEX_VERSION}.tar.gz"
    local temp_dir=$(mktemp -d)
    
    print_status "Downloading LatencyFleX v${LATENCYFLEX_VERSION}..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$temp_dir/latencyflex.tar.gz" "$download_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_dir/latencyflex.tar.gz" "$download_url"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        print_error "Failed to download LatencyFleX"
        exit 1
    fi
    
    print_status "Extracting LatencyFleX..."
    tar -xzf "$temp_dir/latencyflex.tar.gz" -C "$temp_dir"
    
    echo "$temp_dir/latencyflex-wine-v${LATENCYFLEX_VERSION}"
}

# Find the latest Proton installation
find_proton_dir() {
    local proton_dir=$(ls -d $PROTON_DIR 2>/dev/null | sort -V | tail -n1)
    
    if [ -z "$proton_dir" ]; then
        print_error "No Proton installation found in $PROTON_DIR"
        exit 1
    fi
    
    echo "$proton_dir"
}

# Install LatencyFleX files to Proton
install_to_proton() {
    local latencyflex_dir="$1"
    local proton_dir="$2"
    local proton_lib_dir="$proton_dir/dist/lib64"
    
    if [ ! -d "$proton_lib_dir" ]; then
        proton_lib_dir="$proton_dir/dist/lib"
        if [ ! -d "$proton_lib_dir" ]; then
            print_error "Proton lib directory not found in $proton_dir/dist"
            exit 1
        fi
    fi
    
    print_status "Installing LatencyFleX to Proton: $proton_dir"
    
    # Copy files for Wine 7.x+ (Proton uses recent Wine versions)
    cp "$latencyflex_dir/x86_64-unix/latencyflex_layer.so" "$proton_lib_dir/wine/x86_64-unix/"
    cp "$latencyflex_dir/x86_64-windows/latencyflex_layer.dll" "$proton_lib_dir/wine/x86_64-windows/"
    cp "$latencyflex_dir/x86_64-windows/latencyflex_wine.dll" "$proton_lib_dir/wine/x86_64-windows/"
    
    print_status "LatencyFleX Proton installation completed"
}

# Create symlinks for a specific game
setup_game_prefix() {
    local appid="$1"
    local prefix_dir="$COMPATDATA_DIR/$appid/pfx"
    
    if [ ! -d "$prefix_dir" ]; then
        print_warning "Game prefix not found for appid $appid"
        return 1
    fi
    
    print_status "Setting up symlinks for appid $appid..."
    
    # Create symlinks in the game's prefix
    ln -sf "../../../latencyflex_layer.dll" "$prefix_dir/drive_c/windows/system32/latencyflex_layer.dll"
    ln -sf "../../../latencyflex_wine.dll" "$prefix_dir/drive_c/windows/system32/latencyflex_wine.dll"
    
    print_status "Symlinks created for appid $appid"
}

# Install DXVK-NVAPI with LatencyFleX integration
install_dxvk_nvapi() {
    local proton_dir="$1"
    local nvapi_version="0.5.3"  # Minimum version with LatencyFleX support
    local nvapi_url="https://github.com/jp7677/dxvk-nvapi/releases/download/v${nvapi_version}/dxvk-nvapi-v${nvapi_version}.tar.gz"
    local temp_dir=$(mktemp -d)
    
    print_status "Downloading DXVK-NVAPI v${nvapi_version}..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$temp_dir/dxvk-nvapi.tar.gz" "$nvapi_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_dir/dxvk-nvapi.tar.gz" "$nvapi_url"
    else
        print_error "Neither curl nor wget found"
        return 1
    fi
    
    if [ $? -ne 0 ]; then
        print_error "Failed to download DXVK-NVAPI"
        return 1
    fi
    
    print_status "Extracting DXVK-NVAPI..."
    tar -xzf "$temp_dir/dxvk-nvapi.tar.gz" -C "$temp_dir"
    
    # Copy nvapi64.dll to Proton
    local nvapi_dir="$temp_dir/dxvk-nvapi-v${nvapi_version}"
    local proton_nvapi_dir="$proton_dir/dist/lib64/wine/nvapi"
    
    mkdir -p "$proton_nvapi_dir"
    cp "$nvapi_dir/x64/nvapi64.dll" "$proton_nvapi_dir/"
    
    print_status "DXVK-NVAPI installed to Proton"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Main function
main() {
    print_status "Starting LatencyFleX Proton installation..."
    
    check_dependencies
    
    # Download LatencyFleX
    local latencyflex_dir=$(download_latencyflex)
    
    # Find Proton directory
    local proton_dir=$(find_proton_dir)
    print_status "Found Proton installation: $proton_dir"
    
    # Install LatencyFleX to Proton
    install_to_proton "$latencyflex_dir" "$proton_dir"
    
    # Install DXVK-NVAPI
    install_dxvk_nvapi "$proton_dir"
    
    # Ask user for game appid to set up symlinks
    print_status "Would you like to set up LatencyFleX for a specific game?"
    read -p "Enter the Steam AppID (or press Enter to skip): " appid
    
    if [ -n "$appid" ]; then
        setup_game_prefix "$appid"
    else
        print_warning "You can set up symlinks later by running: $0 --setup-appid <APPID>"
    fi
    
    print_status "Installation completed!"
    print_warning "Remember to enable LatencyFleX in your game's configuration"
    
    # Cleanup
    rm -rf "$(dirname "$latencyflex_dir")"
}

# Handle command line arguments
case "$1" in
    --setup-appid)
        if [ -z "$2" ]; then
            print_error "Please provide an AppID"
            exit 1
        fi
        setup_game_prefix "$2"
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --setup-appid APPID   Set up symlinks for a specific game AppID"
        echo "  --help, -h           Show this help message"
        echo ""
        echo "If no options are provided, the script will perform a full installation."
        ;;
    *)
        main
        ;;
esac