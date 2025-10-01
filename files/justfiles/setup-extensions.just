# vim: set ft=make :

# Enables extensions
enable-extensions:
    #!/usr/bin/env bash
    gsettings set org.gnome.shell disable-user-extensions false
    
# Disables extensions
disable-extensions:
    #!/usr/bin/env bash
    gsettings set org.gnome.shell disable-user-extensions true