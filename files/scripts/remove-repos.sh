#!/usr/bin/bash

REPOS="/etc/yum.repos.d/"

set -eoux pipefail

echo "Removing unused dnf repos."
rm $REPOS/google-chrome.repo
rm $REPOS/rpmfusion-nonfree-nvidia-driver.repo
rm $REPOS/rpmfusion-nonfree-steam.repo

