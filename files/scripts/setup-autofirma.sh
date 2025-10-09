#!/usr/bin/env bash
set -oue pipefail

curl -O https://firmaelectronica.gob.es/content/dam/firmaelectronica/descargas-software/autofirma19/Autofirma_Linux_Fedora.zip

unzip Autofirma_Linux_Fedora.zip
dnf5 install -y java-21-openjdk
dnf5 install -y ./autofirma-*.noarch_FEDORA.rpm

rm Autofirma_Linux_Fedora.zip
rm gpg_sgad_publickey.asc
rm autofirma-*.noarch_FEDORA.rpm
