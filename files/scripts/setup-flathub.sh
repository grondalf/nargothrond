#!/usr/bin/bash

set -euo pipefail

# Find Flatpak apps originally installed from the Fedora remote (but not the runtime itself)
fedora_flatpaks=()
while IFS= read -r line; do
    fedora_flatpaks+=("$line")
done < <(flatpak list --columns=application,origin | awk '$2 == "fedora" && $1 !~ /^org\.fedoraproject\.Platform/ {print $1}')

if [ "${#fedora_flatpaks[@]}" -eq 0 ]; then
    echo "No Fedora repo Flatpak applications found. No action required."
    exit 0
fi

# Remove Fedora Flatpak remotes if present
if flatpak remotes --columns=name | grep -qx "fedora"; then
    echo "Removing Fedora Flatpak repo..."
    flatpak remote-delete fedora --force
fi

# Add the unfiltered Flathub remote (if not already added)
if ! flatpak remotes --columns=name | grep -qx "flathub"; then
    echo "Adding unfiltered Flathub remote..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
else
    echo "Ensuring Flathub is unfiltered and enabled..."
    flatpak remote-modify --no-filter --enable flathub
fi

# Reinstall Fedora-sourced apps from Flathub
echo "Reinstalling default Fedora Flatpak apps from Flathub:"
for app in "${fedora_flatpaks[@]}"; do
    echo "Reinstalling $app from Flathub..."
    flatpak install --system --assumeyes flathub "$app"
done

echo "Operation complete."
