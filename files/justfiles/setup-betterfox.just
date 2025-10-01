# vim: set ft=make :

# Setup Betterfox for Firefox Flatpak
setup-betterfox:
    #!/usr/bin/env bash

    # Remove existing .mozilla folder and link Firefox flatpak cache to .mozilla
    rm -drf "$HOME/.mozilla"

    # Create a temporary directory in /tmp
    TMP_DIR=$(mktemp -d -p /tmp)

    # Clone the Betterfox repository into the temporary directory
    git clone https://github.com/grondalf/Betterfox.git "$TMP_DIR"

    # Change to the Betterfox directory inside the temp folder
    cd "$TMP_DIR/" || { echo "Failed to access cloned repo directory"; exit 1; }

    # Run the install.py script using python3
    python3 install.py

    # Return to home directory
    cd ~

    # Remove the temporary directory and all its contents
    rm -rf "$TMP_DIR"

    echo "Installation complete and temporary files cleaned up."