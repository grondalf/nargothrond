# vim: set ft=make :

# Enables CPU undervolting
enable-undervolting:
    #!/usr/bin/env bash
    systemctl enable --now throttled.service

# Disables CPU undervolting
disable-undervolting:
    #!/usr/bin/env bash
    systemctl disable throttled.service