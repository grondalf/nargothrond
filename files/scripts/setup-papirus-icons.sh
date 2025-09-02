#!/usr/bin/env bash
set -oue pipefail

wget -qO- https://github.com/grondalf/papirus-icon-theme/blob/master/install.sh | sh
wget -qO- https://github.com/grondalf/papirus-folders/blob/master/install.sh | sh

papirus-folders -C adwaita --theme Papirus
papirus-folders -C adwaita --theme Papirus-Light
papirus-folders -C adwaita --theme Papirus-Dark
