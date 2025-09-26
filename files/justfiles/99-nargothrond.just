# vim: set ft=make :

# Adds zstd encryption to kargs
fix-zstd-kargs:
    #!/usr/bin/env bash
    if ! rpm-ostree kargs | grep zstd >> /dev/null; then
        echo "Adding kargs"
        sudo rpm-ostree kargs --delete=rootflags=subvol=root --append=rootflags=subvol=root,compress=zstd:1,x-systemd.device-timeout=0
    else
        echo "zstd kargs already in place, skipping..."
    fi

# Sets current user as operator for tailscale
tailscale-set-operator:
    #!/usr/bin/env bash
    sudo tailscale set --operator=$USER
    
# Enables undervolting:
enable-undervolting:
    #!/usr/bin/env bash
    systemctl enable --now intel-undervolt.service
    sudo intel-undervolt apply
    
# Enables supergfxctl
enable-supergfxctl:
    #!/usr/bin/env bash
    systemctl enable --now supergfxd.service
    gnome-extensions enable supergfxctl-gex
    
# Disables supergfxctl
disable-supergfxctl:
    #!/usr/bin/env bash
    systemctl disable supergfxd.service
    gnome-extensions disable supergfxctl-gex
    
# Enables extensions
enable-extensions:
    #!/usr/bin/env bash
    gsettings set org.gnome.shell disable-user-extensions false
    
# Disables extensions
disable-extensions:
    #!/usr/bin/env bash
    gsettings set org.gnome.shell disable-user-extensions true

# Setup LatencyFlex Proton extensions
setup-latencyflex:
    #!/usr/bin/env bash
    chmod +x /usr/bin/setup-lantencyflex.sh
    ./usr/bin/setup-latencyflex.sh
    