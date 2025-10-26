#!/bin/bash

set -oue pipefail

# Specify the exact version and MD% sum:
VERSION="1.6.8-1"
EXPECTED_MD5="fcb93e179b0668894369a39dcf9164b5"

BASE_URL="https://www.dnielectronico.es/descargas/distribuciones_linux"
RPM_FILENAME="libpkcs11-dnie-${VERSION}.x86_64.rpm"

echo "Downloading ${RPM_FILENAME} from ${BASE_URL}/${RPM_FILENAME}"
curl -O "${BASE_URL}/${RPM_FILENAME}"

if [[ ! -f "${RPM_FILENAME}" ]]; then
    echo "Download failed: ${RPM_FILENAME} not found."
    exit 1
fi

echo "Calculating md5sum..."
ACTUAL_MD5=$(md5sum "${RPM_FILENAME}" | awk '{print $1}')

if [[ "${ACTUAL_MD5}" != "${EXPECTED_MD5}" ]]; then
    echo "MD5 checksum FAILED! Expected: ${EXPECTED_MD5}, Got: ${ACTUAL_MD5}"
    echo "Skipping installation and deleting RPM."
    rm -f "${RPM_FILENAME}"
    exit 2
else
    echo "MD5 checksum OK. Proceeding with installation."
    rpm - i"${RPM_FILENAME}"
    rm -f "${RPM_FILENAME}"
fi

