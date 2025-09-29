# Nargothrond OS - AI Coding Agent Instructions

## Project Overview
Nargothrond OS is a personal immutable atomic Linux image based on Fedora Silverblue, built using the BlueBuild framework. This is a container-based OS image with NVIDIA drivers, customized GNOME environment, and gaming optimizations.

## Architecture & Key Components

### BlueBuild Module System
The project uses a modular configuration approach through YAML recipes in `/recipes/`:
- `recipe.yml` - Main orchestrator defining build order and base image
- Module execution order: akmods → files → dnf → script → flatpaks → gnome-extensions → gschema-overrides → cleanup
- Each module is a separate YAML file following BlueBuild schema

### Image Build Process
- Base: `ghcr.io/ublue-os/silverblue-main` (Fedora 42)
- Custom akmods source: `ghcr.io/grondalf/modules/akmods:latest` for NVIDIA drivers
- Builds automatically on schedule (Wed/Fri/Sun 06:00 UTC) and on pushes
- Uses container layering with cosign signing for verification

### File Organization Patterns
```
files/
├── dnf/          # DNF repository configurations
├── gschema-overrides/  # GNOME settings (zz1=settings, zz2=extensions, zz3=extension-settings)
├── scripts/      # Setup scripts for build-time execution  
├── system/       # System files copied to specific paths
└── justfiles/    # Just command definitions
```

## Development Workflows

### Making Changes
1. **Package Management**: Edit `recipes/dnf.yml` for RPM packages, `recipes/default-flatpaks.yml` for Flatpaks
2. **GNOME Customization**: Use numbered gschema overrides (zz1, zz2, zz3) for load order
3. **System Services**: Configure via `recipes/systemd.yml` - note the custom bootc service overrides
4. **Build Scripts**: Add to `files/scripts/` and reference in `recipes/script.yml`

### Key Conventions
- **Service Management**: Disables `rpm-ostreed-automatic.timer` in favor of `bootc-fetch-apply-updates.service`
- **COPR Repositories**: Heavy use of COPR repos for gaming/performance packages (system76-scheduler, latencyflex, etc.)
- **NVIDIA Integration**: Uses negativo17 repos, not default Fedora packages
- **Gaming Focus**: Includes gamemode, latencyflex, system76-scheduler for performance

### Testing & Verification
- Local testing: Build with BlueBuild CLI before pushing
- Image verification: `cosign verify --key cosign.pub ghcr.io/grondalf/nargothrond`
- Manual rebuild: Use workflow_dispatch trigger in GitHub Actions

### Script Patterns
Build scripts follow this pattern:
```bash
#!/usr/bin/env bash
set -oue pipefail
# Download, install, cleanup in single RUN layer
```

## Critical Dependencies
- **Base Image**: Universal Blue Silverblue (tracks Fedora releases)
- **NVIDIA Drivers**: From negativo17, not RPMFusion
- **BlueBuild Schema**: All YAML files use schema validation
- **Custom AKMODS**: Self-hosted module for driver compilation

## Debugging Common Issues
- **Build Failures**: Check if base image updated, COPR repos available
- **NVIDIA Issues**: Verify akmods module build status separately
- **GNOME Extensions**: ID numbers in `gnome-extensions.yml` may break if extensions are removed from store
- **systemd Services**: Custom overrides in `files/system/common/` for bootc behavior