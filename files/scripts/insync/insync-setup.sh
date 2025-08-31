#!/usr/bin/env bash
set -oue pipefail
echo "Importing Insync GPG key..."
rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key

echo "Creating Insync repo file..."
tee /etc/yum.repos.d/insync.repo > /dev/null <<EOF
[insync]
name=insync repo
baseurl=http://yum.insync.io/fedora/\$releasever/
gpgcheck=1
gpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
enabled=1
metadata_expire=120m
EOF

echo "Installing Insync and Insync-Nautilus..."
rpm-ostree install -y insync insync-nautilus

echo "Installation complete."

