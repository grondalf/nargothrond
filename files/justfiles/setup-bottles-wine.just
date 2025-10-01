# vim: set ft=make :

# Sets current user as operator for tailscale
setup-bottles-wine:
    #!/usr/bin/env bash

    APP_BOTTLE="Applications"
    GAME_BOTTLE="Games"
    BIN_DIR="$HOME/.local/bin"
    WINE_WRAPPER="$BIN_DIR/wine"
    PROTON_WRAPPER="$BIN_DIR/proton"

    # Ensure ~/.local/bin exists and is in PATH
    mkdir -p ~/.local/bin
    PATH="$HOME/.local/bin:$PATH"

    # Check Bottles installation
    if command -v flatpak &>/dev/null && flatpak info com.usebottles.bottles &>/dev/null; then
        CMD="flatpak run --command='bottles-cli' com.usebottles.bottles"
    elif command -v bottles-cli &>/dev/null; then
        CMD="bottles-cli"
    else
        echo "Bottles is not installed as Flatpak or RPM."
        exit 1
    fi

    # Create default bottles
    $CMD new --bottle-name "$APP_BOTTLE" --environment application
    $CMD new --bottle-name "$GAME_BOTTLE" -environment gaming

    # Create the wrapper scripts
    cat <<EOF > "$WINE_WRAPPER"
    #!/bin/sh
    $CMD run -b $APP_BOTTLE -e "$@"
    EOF

    cat <<EOF > "$PROTON_WRAPPER"
    #!/bin/sh
    $CMD run -b $GAME_BOTTLE -e "$@"
    EOF
    
    chmod +x "$WINE_WRAPPER"
    chmod +x "$PROTON_WRAPPER"

    echo "The wine and proton commands are now set up in $WINE_WRAPPER and $PROTON_WRAPPER"

