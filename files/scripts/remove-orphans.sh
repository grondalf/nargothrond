#!/usr/bin/bash
set -euo pipefail

echo "Cleaning up orphaned DNF packages and leftovers..."

# Remove orphaned dependencies no longer needed by any installed package
dnf5 autoremove -y

# Optional: remove cached package files to free disk space
dnf5 clean packages

# Remove extra orphaned packages installed but not part of any enabled repo
mapfile -t orphans < <(dnf5 repoquery --extras -q 2>/dev/null || true)
if [ ${#orphans[@]} -gt 0 ]; then
    echo "Removing extra orphaned packages:"
    printf '%s\n' "${orphans[@]}"
    dnf5 remove -y "${orphans[@]}"
else
    echo "No extra orphaned packages found."
fi

echo "Cleaning up unused Flatpak runtimes and unused Flatpak packages..."

# Remove unused Flatpak runtimes and extensions
flatpak uninstall --unused -y || echo "No unused Flatpak runtimes/extensions to remove."

# List Flatpak apps that are orphaned/not from known remotes
mapfile -t orphaned_flatpaks < <(flatpak list --app --columns=application,origin 2>/dev/null | awk '$2 !~ /(flathub|fedora)/ {print $1}' || true)
if [ ${#orphaned_flatpaks[@]} -gt 0 ]; then
    echo "Removing orphaned Flatpak applications:"
    printf '%s\n' "${orphaned_flatpaks[@]}"
    for app in "${orphaned_flatpaks[@]}"; do
        flatpak uninstall -y "$app"
    done
else
    echo "No orphaned Flatpak applications found."
fi

echo "Cleanup complete."
