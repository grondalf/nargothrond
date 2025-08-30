# vim: set ft=make :

# Adds zstd encryption to kargs
nimbus-fix-zstd-kargs:
    #!/usr/bin/env bash
    if ! rpm-ostree kargs | grep zstd >> /dev/null; then
        echo "Adding kargs"
        sudo rpm-ostree kargs --delete=rootflags=subvol=root --append=rootflags=subvol=root,compress=zstd:1,x-systemd.device-timeout=0
    else
        echo "zstd kargs already in place, skipping..."
    fi

# Sets current user as operator for tailscale
nimbus-tailscale-set-operator:
    #!/usr/bin/env bash
    sudo tailscale set --operator=$USER
    
# Enables undervolting:
nimbus-undervolt-services-setup:
    #!/usr/bin/env bash
    systemctl enable intel-undervolt
    sudo intel-undervolt apply
