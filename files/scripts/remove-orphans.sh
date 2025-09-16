#!/usr/bin/bash
set -euox pipefail

echo "Cleaning up orphaned DNF packages and leftovers..."

# Remove orphaned dependencies no longer needed by any installed package
sudo dnf5 autoremove -y

# Optional: remove cached package files to free disk space
sudo dnf5 clean packages

# Remove extra orphaned packages installed but not part of any enabled repo
orphans=$(dnf5 repoquery --extras -q || true)
if [ -n "$orphans" ]; then
  echo "Removing extra orphaned packages: $orphans"
  sudo dnf5 remove -y $orphans
else
  echo "No extra orphaned packages found."
fi

echo "Cleaning up unused Flatpak runtimes and unused Flatpak packages..."

# Remove unused Flatpak runtimes and extensions
flatpak uninstall --unused --assumeyes || echo "No unused Flatpak runtimes/extensions to remove."

# List Flatpak apps that are orphaned/not referenced by any user
orphaned_flatpaks=$(flatpak list --app --columns=application,origin | grep -vE 'flathub|fedora' | awk '{print $1}' || true)
if [ -n "$orphaned_flatpaks" ]; then
  echo "Removing orphaned Flatpak applications:"
  echo "$orphaned_flatpaks"
  echo "$orphaned_flatpaks" | xargs -r flatpak uninstall --assumeyes
else
  echo "No orphaned Flatpak applications found."
fi

echo "Cleanup complete."
