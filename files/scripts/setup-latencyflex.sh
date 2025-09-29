#!/bin/bash

# Detect if we're running on Silverblue or Workstation
if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ "$VARIANT_ID" == "silverblue" ] || [ "$VARIANT_ID" == "kinoite" ]; then
        IS_SILVERBLUE=true
    else
        IS_SILVERBLUE=false
    fi
else
    IS_SILVERBLUE=false
fi

# Detect Steam installation type
function detect_steam_install() {
    # Check for Flatpak first
    if flatpak list --app | grep -q com.valvesoftware.Steam; then
        echo "flatpak"
    # Check for RPM
    elif rpm -q steam > /dev/null 2>&1; then
        echo "rpm"
    else
        echo "unknown"
    fi
}

STEAM_TYPE=$(detect_steam_install)

# Set paths based on detection
if [ "$STEAM_TYPE" = "flatpak" ]; then
    # Flatpak Steam paths
    FLATPAK_STEAM_DIR="$HOME/.var/app/com.valvesoftware.Steam/data/Steam"
    DEFAULT_STEAM_DIRECTORY="$FLATPAK_STEAM_DIR"
    
    # LatencyFlex libraries for Flatpak
    if [ "$IS_SILVERBLUE" = true ]; then
        # On Silverblue, Flatpak applications use the host's /usr
        latencyflex_wine_dll="/usr/lib/wine/x86_64-windows/latencyflex_wine.dll"
        latencyflex_layer_dll="/usr/lib/wine/x86_64-windows/latencyflex_layer.dll"
        latencyflex_layer_so="/usr/lib/wine/x86_64-unix/latencyflex_layer.so"
    else
        # On Workstation with Flatpak
        latencyflex_wine_dll="/usr/lib/wine/x86_64-windows/latencyflex_wine.dll"
        latencyflex_layer_dll="/usr/lib/wine/x86_64-windows/latencyflex_layer.dll"
        latencyflex_layer_so="/usr/lib/wine/x86_64-unix/latencyflex_layer.so"
    fi
else
    # RPM Steam paths
    DEFAULT_STEAM_DIRECTORY="$HOME/.local/share/Steam"
    
    # LatencyFlex libraries for RPM
    latencyflex_wine_dll="/usr/lib/wine/x86_64-windows/latencyflex_wine.dll"
    latencyflex_layer_dll="/usr/lib/wine/x86_64-windows/latencyflex_layer.dll"
    latencyflex_layer_so="/usr/lib/wine/x86_64-unix/latencyflex_layer.so"
fi

# This will be prompted for at runtime
promptSteamDir=true

# Display detected configuration
echo "Detected system: $([ "$IS_SILVERBLUE" = true ] && echo "Fedora Silverblue" || echo "Fedora Workstation")"
echo "Detected Steam installation: $STEAM_TYPE"
echo "Using Steam directory: $DEFAULT_STEAM_DIRECTORY"
echo ""

# Prompts [y/N] countinue prompt
function promptCountinue {
    read -p "$1[y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Installing..."
    else
        echo "Aborted by user."
        exit
    fi
}

# Returns $1 if $2 is empty
function defaultTo {
    if [ -n "$2" ]; then
        echo $2 
    else
        echo $1
    fi
}

# Symlinks DLLs to specified location
function linkDLLs {
    # For unknown reason the symlinks here are broken, seen in issue https://github.com/ishitatsuyuki/LatencyFleX/issues/5
    # ln -s "$latencyflex_wine_dll" "$1"
    # ln -s "$latencyflex_layer_dll" "$1"

    cp "$latencyflex_wine_dll" "$1"
    cp "$latencyflex_layer_dll" "$1"
}

# copies dxvk.conf to specified location
function copyDXVKConf {
    cp "dxvk.conf" "$1"
}

# Installs to game with game directory name(not full path), and game ID
function installToGame {
    # Getting steam directory
    if [ "$promptSteamDir" = true ]; then
        echo "Enter Steam directory, leave blank for \"$DEFAULT_STEAM_DIRECTORY\":"
        read steamDir
    else
        steamDir=""
    fi

    local steamDir=$(defaultTo $DEFAULT_STEAM_DIRECTORY $steamDir)
    echo "Using Steam directory: $steamDir"

    # Check if Steam directory exists
    if [ ! -d "$steamDir" ]; then
        echo "Error: Steam directory '$steamDir' does not exist!"
        exit 1
    fi

    # Check if game compatdata exists
    if [ ! -d "$steamDir/steamapps/compatdata/$2" ]; then
        echo "Error: Compatdata directory for game ID $2 not found!"
        echo "Make sure the game is installed and you have the correct game ID."
        exit 1
    fi

    # Check if game directory exists
    if [ ! -d "$steamDir/steamapps/common/$1" ]; then
        echo "Warning: Game directory '$steamDir/steamapps/common/$1' not found!"
        echo "The game might be installed in a different location."
    fi

    # Installing
    promptCountinue "Install dxvk.conf into \"$steamDir/steamapps/common/$1\", and libraries into \"$steamDir/steamapps/compatdata/$2/pfx/drive_c/windows/system32\"?"

    # Create target directories if they don't exist
    mkdir -p "$steamDir/steamapps/compatdata/$2/pfx/drive_c/windows/system32"
    mkdir -p "$steamDir/steamapps/common/$1"

    linkDLLs "$steamDir/steamapps/compatdata/$2/pfx/drive_c/windows/system32"
    copyDXVKConf "$steamDir/steamapps/common/$1"

    echo "Installation finished, remember to have LatencyFlex installed on the system/proton, as well as the proper launch options for LatencyFlex to work ingame."
}

# Installs to proton version with full path
function installToProton {
    promptCountinue "Install libraries into \"$1\"?"

    # Check if Proton directory exists
    if [ ! -d "$1" ]; then
        echo "Error: Proton directory '$1' does not exist!"
        exit 1
    fi

    # Create target directories if they don't exist
    mkdir -p "$1/files/lib64/wine/x86_64-windows"
    mkdir -p "$1/files/lib64/wine/x86_64-unix"

    linkDLLs "$1/files/lib64/wine/x86_64-windows"
    
    # see function linkDLLs for change
    # ln -s "$latencyflex_layer_so" "$1/files/lib64/wine/x86_64-unix"
    cp "$latencyflex_layer_so" "$1/files/lib64/wine/x86_64-unix"

    echo "Installation finished, remember to install LatencyFlex for the individual games you plan to use LatencyFlex with."
}

# Handling parameters
echo -e "Make sure you have LatencyFlex installed on the system before using, as this installer copies files from the system install.\n"
if [[ "$1" == "--game" ]]; then 
    if [ -z "$2" ] || [ -z "$3" ]; then
        echo "Error: --game requires both game directory name and game ID"
        echo "Usage: $0 --game \"Game Name\" 1234567"
        exit 1
    fi
    installToGame "$2" "$3"
elif [[ "$1" == "--proton" ]]; then
    if [ -z "$2" ]; then
        echo "Error: --proton requires a proton path"
        echo "Usage: $0 --proton \"/path/to/proton\""
        exit 1
    fi
    installToProton "$2"
else
    echo "Install script to install LatencyFlex to games and proton versions easily.
    
System detection:
  - Detected: $([ "$IS_SILVERBLUE" = true ] && echo "Fedora Silverblue" || echo "Fedora Workstation")
  - Steam: $STEAM_TYPE
  - Default Steam directory: $DEFAULT_STEAM_DIRECTORY

Usage:
  --game    Installs LatencyFlex to a specified game directory name + game ID
            Example: '$0 --game \"Apex Legends\" 1172470'
            
  --proton  Installs LatencyFlex to a specified proton full path
            Example: '$0 --proton \"$DEFAULT_STEAM_DIRECTORY/compatibilitytools.d/GE-Proton8-21/\"'"
fi
