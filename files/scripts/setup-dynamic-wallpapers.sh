#!/usr/bin/bash

set -eoux pipefail

# List of all theme codes from the repository
themes=(
  Lakeside
  A_Certain_Magical_Index
  Exodus
  Minimal-Mojave
  Mojave
  MojaveV2
  Big_Sur_Beach
  Firewatch
  Lakeside-2
  Big_Sur
  Fuji
  Catalina
)

for theme in "${themes[@]}"; do
  echo "Installing theme: $theme"
  curl -s https://wallpapers.manishk.dev/install.sh | bash -s "$theme"
done

echo "All dynamic GNOME wallpapers from the repository have been installed."

