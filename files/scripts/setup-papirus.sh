#!/usr/bin/bash

set -eoux pipefail

echo "Downloading and installing Papirus icon theme from source..."
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh | sh

echo "Downloading and installing papirus-folders from source..."
wget -qO- https://git.io/papirus-folders-install | sh

echo "Setting adwaita papirus folders theme"
papirus-folders -C adwaita --theme Papirus
papirus-folders -C adwaita --theme Papirus-Light
papirus-folders -C adwaita --theme Papirus-Dark

echo "Both Papirus icon theme and papirus-folders have been installed."
