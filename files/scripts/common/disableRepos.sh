#!/usr/bin/bash

REPOS="/etc/yum.repos.d/"

set -eoux pipefail

dnf config-manager setopt fedora-cisco-openh264.enabled=0
rm $REPOS/google-chrome.repo
rm $REPOS/rpmfusion-nonfree-nvidia-driver.repo
rm $REPOS/rpmfusion-nonfree-steam.repo
