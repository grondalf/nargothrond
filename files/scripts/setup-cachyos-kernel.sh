#!/usr/bin/bash
# If you use SELinux, you need to enable the necessary policy to be able to load kernel modules:

sudo setsebool -P domain_kernel_load_modules on
