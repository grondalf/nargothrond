#!/usr/bin/bash

REPOS="/etc/yum.repos.d/"

set -eoux pipefail

echo "Deleting unnecessary dnf repos."
rm $REPOS/google-chrome.repo
rm $REPOS/rpmfusion-nonfree-nvidia-driver.repo
rm $REPOS/rpmfusion-nonfree-steam.repo

echo "Replacing Fedora's default Flatpak repo with the unfiltered one."
flatpak remote-delete fedora
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --no-filter --enable flathub

echo "Reinstalling default applications."
flatpak install --reinstall --system --assumeyes flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application)

echo "Unnecessary repos have been deleted." 

