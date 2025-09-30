# vim: set ft=make :

# Sets current user as operator for tailscale
tailscale-set-operator:
    #!/usr/bin/env bash
    sudo tailscale set --operator=$USER

# Turn on taitscale
tailscale-on:
    #!/usr/bin/env bash
    sudo systemctl enable --now tailscaled
    sudo tailscale up --accept-dns

# Turns off tailscale
tailscale off:
     #!/usr/bin/env bash
    sudo tailscale down
    sudo systemctl stop tailscaled
    sudo systemctl disable tailscaled
