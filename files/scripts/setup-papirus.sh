#!/bin/bash
set -euo pipefail

print_title() {
    echo -e "\e[1;35m=========================================\e[0m"
    echo -e "\e[1;35m Papirus & Hardcode-Tray Icons Installer \e[0m"
    echo -e "\e[1;35m=========================================\e[0m"
}
                                                                                                  
print_title

echo "Downloading and installing Papirus icon theme from source..."
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh | sudo sh

echo "Downloading and installing papirus-folders from source..."
wget -qO- https://git.io/papirus-folders-install | sudo sh

echo "Setting Adwaita Papirus folders theme..."
papirus-folders -C adwaita --theme Papirus
papirus-folders -C adwaita --theme Papirus-Light
papirus-folders -C adwaita --theme Papirus-Dark

echo "Installing dependencies for building Hardcode-Tray icons..."
sudo dnf install -y git meson gdk-pixbuf2-devel gtk3-devel python3 python3-gobject gobject-introspection-devel librsvg2-tools ninja-build

echo "Cloning Hardcode-Tray repository..."
git clone https://github.com/bilelmoussaoui/Hardcode-Tray.git
cd Hardcode-Tray

echo "Compiling Hardcode-Tray..."
meson builddir --prefix=/usr

echo "Installing Hardcode-Tray..."
sudo ninja -C builddir install

echo "Cleaning up cloned repository..."
cd ..
rm -rf Hardcode-Tray

echo "Removing unnecessary build dependencies..."
sudo dnf remove -y meson gdk-pixbuf2-devel gtk3-devel gobject-introspection-devel ninja-build

echo -e "\e[1;32mInstallation complete: Papirus icon themes and Hardcode-Tray installed. Build dependencies removed.\e[0m"

