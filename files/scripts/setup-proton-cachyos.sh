#!/bin/bash

set -eou pipefail

# Variables - configure as needed
ARCH_PATTERN="v3"
REPO="CachyOS/proton-cachyos"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
STEAM_DIR="$HOME/.steam/root/compatibilitytools.d"
FLATPAK_DIR="$HOME/.var/app/com.valvesoftware.Steam/.steam/compatibilitytools.d"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}Fetching latest proton-cachyos release assets...${NC}"

ASSETS_JSON=$(curl -s "$API_URL" | jq -r '.assets')

TXZ_ASSET=$(echo "$ASSETS_JSON" | jq -r --arg PATTERN "^proton-cachyos.*${ARCH_PATTERN}\\.tar\\.xz$" \
  'map(select(.name | test($PATTERN))) | .[0]')

if [ -z "$TXZ_ASSET" ]; then
  echo -e "${RED}Error:${NC} No proton-cachyos tar.xz file matching pattern found."
  exit 1
fi

TXZ_NAME=$(echo "$TXZ_ASSET" | jq -r '.name')
TXZ_URL=$(echo "$TXZ_ASSET" | jq -r '.browser_download_url')
CHECKSUM_NAME="${TXZ_NAME%.tar.xz}.sha512sum"

CHECKSUM_ASSET=$(echo "$ASSETS_JSON" | jq -r --arg NAME "$CHECKSUM_NAME" \
  'map(select(.name == $NAME)) | .[0]')

if [ "$CHECKSUM_ASSET" == "null" ]; then
  echo -e "${RED}Error:${NC} Checksum file ${YELLOW}$CHECKSUM_NAME${NC} not found."
  exit 1
fi

CHECKSUM_URL=$(echo "$CHECKSUM_ASSET" | jq -r '.browser_download_url')

echo -e "${CYAN}Downloading package:${NC} ${YELLOW}$TXZ_NAME${NC}"
curl -L -o "$TXZ_NAME" "$TXZ_URL"

echo -e "${CYAN}Downloading checksum:${NC} ${YELLOW}$CHECKSUM_NAME${NC}"
curl -L -o "$CHECKSUM_NAME" "$CHECKSUM_URL"

echo -e "${CYAN}Verifying checksum...${NC}"
if sha512sum -c "$CHECKSUM_NAME" | grep "$TXZ_NAME" > /dev/null; then
  echo -e "${GREEN}Checksum verified successfully.${NC}"
else
  echo -e "${RED}Checksum verification failed!${NC}"
  exit 2
fi

echo -e "${CYAN}Extracting package...${NC}"
tar -xJvf "$TXZ_NAME"

PROTON_FOLDER=$(tar -tf "$TXZ_NAME" | head -1 | cut -f1 -d"/")

echo -e "${CYAN}Installing Proton-CachyOS to Steam directories...${NC}"

mkdir -p "$STEAM_DIR"
cp -r "$PROTON_FOLDER" "$STEAM_DIR/"

if [ -d "$HOME/.var/app/com.valvesoftware.Steam/" ]; then
  mkdir -p "$FLATPAK_DIR"
  cp -r "$PROTON_FOLDER" "$FLATPAK_DIR/"
fi

echo -e "${CYAN}Cleaning up temporary files...${NC}"
rm -rf "$TXZ_NAME" "$CHECKSUM_NAME" "$PROTON_FOLDER"

echo -e "${GREEN}Proton-CachyOS v3 installed successfully.${NC}"
echo -e "${YELLOW}Please restart Steam and select it from the compatibility tools.${NC}"

