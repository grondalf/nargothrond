#!/usr/bin/bash

REPOS="/etc/yum.repos.d"

set -eou pipefail

echo "Checking and removing unused dnf repos."

# Remove repos only if they exist
if [ -f "$REPOS/google-chrome.repo" ]; then
    rm "$REPOS/google-chrome.repo"
    echo "Removed google-chrome.repo"
else
    echo "google-chrome.repo not found, skipping"
fi

if [ -f "$REPOS/rpmfusion-nonfree-nvidia-driver.repo" ]; then
    rm "$REPOS/rpmfusion-nonfree-nvidia-driver.repo"
    echo "Removed rpmfusion-nonfree-nvidia-driver.repo"
else
    echo "rpmfusion-nonfree-nvidia-driver.repo not found, skipping"
fi

if [ -f "$REPOS/rpmfusion-nonfree-steam.repo" ]; then
    rm "$REPOS/rpmfusion-nonfree-steam.repo"
    echo "Removed rpmfusion-nonfree-steam.repo"
else
    echo "rpmfusion-nonfree-steam.repo not found, skipping"
fi

echo "Done!" 

