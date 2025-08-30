# 🏰 Nargothrond OS &nbsp; [![bluebuild build badge](https://github.com/grondalf/nargothrond/actions/workflows/build.yml/badge.svg)](https://github.com/grondalf/nargothrond/actions/workflows/build.yml)

Nargothrond OS is a personal immutable atomic Fedora image designed for reliability, reproducibility, and minimal maintenance overhead. It is crafted using [BlueBuild](https://blue-build.org/how-to/setup/) with some adjustments taken from [franute's Nimbus-OS](https://github.com/franute/nimbus-os).

## Software Changes:

The following `rpm` packages were added to the base image:
- Propietary NVIDIA Drivers.
- `starship` - for a good-looking prompt.
- `fastfetch` - looks nice to show off.
- `insync` & `insync-nautilus`
- `steam-devices` - for proper gamepad support.
- `uld` - support for Samsung's printers.
- `papirus-icon-theme` - a nice-looking icon set.
- `tailscale` - Private Wireguard VPN
- `java-21-openjdk` - required dependency for Autofirma
- [Autofirma](https://sede.serviciosmin.gob.es/ES-ES/FIRMAELECTRONICA/Paginas/AutoFirma.aspx) - for signing digitally documents using Spanish ID cards.

The following ones are removed:
- `virtualbox-guest-additions`
- `firefox` & `firefox-langpacks`
- `gnome-tour`

Some default `flatpaks` are included:

- Firefox
- Flatseal
- Refine
- Papers
- Firmware
- Extension Manager
- Fragments
- Impression
- Gnome Geary
- Gnome Calculator
- Gnome Calendar
- Gnome Characters
- Gnome Contacts
- Gnome Text Editor
- OnlyOffice
- Stremio
- Spotify
- Steam
- Protontricks
- Heroic Games Launcher
- Proton GE
- AddWater
- AdwSteamGtk
- Telegram
- Adw-gtk3 & Adw-gtk3-dark

## System changes

The `rpm-ostreed-automatic.service` service is disabled in favour of `bootc-fetch-apply-updates.service`.
An override has been set for the latter to avoid automatic reboots.

[QMK](https://qmk.fm/) udev file is added to allow keyboard customisations.

### Gnome Defaults
- Automatic Timezone Enabled
- Default fonts settings changed:
  - Font antialiasing enabled.
  - Font hinting set to *fullt*.
- Numlock on keyboard enabled by default.
- Natural scroll enabled by default for mice.
- Automatically remove old temp and trash files.
- File-chooser to sort directories before files.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/grondalf/nargothrond:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/grondalf/nargothrond:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/grondalf/nargothrond
```
