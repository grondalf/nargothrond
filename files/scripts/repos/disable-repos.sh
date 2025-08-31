#!/usr/bin/bash

REPOS="/etc/yum.repos.d/"

set -eoux pipefail

rm $REPOS/fedora-cisco-openh264.repo
rm $REPOS/google-chrome.repo
rm $REPOS/rpmfusion-nonfree-nvidia-driver.repo
rm $REPOS/rpmfusion-nonfree-steam.repo
