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
    
# Install Dynamic Wallpapers
setup-dynamic-wallpapers:
    #!/usr/bin/env bash
    themes=(
        Lakeside
        A_Certain_Magical_Index
        Exodus
        Minimal-Mojave
        Mojave
        MojaveV2
        Big_Sur_Beach
        Firewatch
        Lakeside-2
        Big_Sur
        Fuji
        Catalina
    )

    for theme in "${themes[@]}"; do
        echo "Installing theme: $theme"
        curl -s https://wallpapers.manishk.dev/install.sh | bash -s "$theme"
    done

    echo "All dynamic GNOME wallpapers from the repository have been installed."
