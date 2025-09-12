#!/usr/bin/bash

set -eoux pipefail

# Check if the symlink or target file exists before adding
if [ ! -e /etc/udev/rules.d/51-android.rules ]; then
    sudo ln -s /usr/share/doc/android-tools/51-android.rules /etc/udev/rules.d/51-android.rules
else
    echo 'Link or file already exists'
fi
