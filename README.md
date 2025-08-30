# 🏰 [Nargothrond](https://tolkiengateway.net/wiki/Nargothrond) OS &nbsp; [![bluebuild build badge](https://github.com/grondalf/nargothrond/actions/workflows/build.yml/badge.svg)](https://github.com/grondalf/nargothrond/actions/workflows/build.yml)

Nargothrond OS is an immutable atomic Fedora image designed for reliability, reproducibility, and minimal maintenance overhead. It is mainly crafted solely **for personal use** using [BlueBuild](https://blue-build.org/how-to/setup/) and some adjustments taken from [franute's Nimbus-OS](https://github.com/franute/nimbus-os).

## Software Changes:

The image comes with NVIDIA propietary drivers and [Autofirma](https://sede.serviciosmin.gob.es/ES-ES/FIRMAELECTRONICA/Paginas/AutoFirma.aspx) pre-installed. Further changes were made buy adding and removing several [rpm packages](recipes/pkgs/rpms.yml) and [flatpaks](recipes/pkgs/flatpaks.yml).

## System changes

The `rpm-ostreed-automatic.service` service is disabled in favour of `bootc-fetch-apply-updates.service`.
An override has been set for the latter to avoid automatic reboots.

### Gnome Defaults
- Automatic Timezone Enabled
- Default fonts settings changed:
  - Font antialiasing enabled.
  - Font hinting set to *full*.
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
