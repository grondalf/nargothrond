#!/bin/bash

setp -eou pipefail

REPO="FilenCloudDienste/filen-desktop"
RPM="Filen_linux_x86_64.rpm"
SUM="Filen_linux_x86_64.rpm.sha256.txt"

# Get latest download URLs
API="https://api.github.com/repos/$REPO/releases/latest"
RPM_URL=$(curl -s $API | grep "browser_download_url" | grep $RPM | cut -d '"' -f 4)
SUM_URL=$(curl -s $API | grep "browser_download_url" | grep $SUM | cut -d '"' -f 4)

# Download files
curl -L -o $RPM $RPM_URL
curl -L -o $SUM $SUM_URL

# Verify checksum
CHECKSUM_EXPECTED=$(cut -d ' ' -f1 $SUM)
CHECKSUM_ACTUAL=$(sha256sum $RPM | cut -d ' ' -f1)

if [ "$CHECKSUM_EXPECTED" == "$CHECKSUM_ACTUAL" ]; then
  echo "Checksum OK, installing $RPM ..."
  dnf5 install $RPM
else
  echo "Checksum mismatch, aborting."
  exit 1
fi

