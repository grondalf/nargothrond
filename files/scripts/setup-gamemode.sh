#!/usr/bin/bash
# Run gamemode with the dedicated NVIDIA GPU

echo 'GAMEMODERUNEXEC="env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only"' | sudo tee -a /etc/environment
