#!/bin/bash

set -euo pipefail

REPO="FilenCloudDienste/filen-desktop"
RPM="Filen_linux_x86_64.rpm"
SUM="Filen_linux_x86_64.rpm.sha256.txt"

# Get latest release URLs
API="https://api.github.com/repos/$REPO/releases/latest"
RPM_URL=$(curl -s "$API" | jq -r ".assets[] | select(.name==\"$RPM\") | .browser_download_url")
SUM_URL=$(curl -s "$API" | jq -r ".assets[] | select(.name==\"$SUM\") | .browser_download_url")

if [[ -z "$RPM_URL" || -z "$SUM_URL" ]]; then
  echo "Failed to retrieve URLs for $RPM and $SUM"
  exit 1
fi

# Download files
curl -L -o "$RPM" "$RPM_URL"
curl -L -o "$SUM" "$SUM_URL"

# Verify checksum
CHECKSUM_EXPECTED=$(cut -d ' ' -f1 "$SUM")
CHECKSUM_ACTUAL=$(sha256sum "$RPM" | cut -d ' ' -f1)

if [[ "$CHECKSUM_EXPECTED" == "$CHECKSUM_ACTUAL" ]]; then
  echo "Checksum OK, installing $RPM ..."
  if command -v dnf5 &>/dev/null; then
    dnf5 install -y "$RPM"
  else
    dnf install -y "$RPM"
  fi
else
  echo "Checksum mismatch, aborting."
  exit 1
fi

