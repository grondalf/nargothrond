# Nargothrond OS

[Nargothrond](https://tolkiengateway.net/wiki/Nargothrond) OS is an immutable atomic image based on [Universal Blue](https://github.com/orgs/ublue-os/packages)'s version of Fedora Silverblue and built using a [BlueBuild](https://blue-build.org/how-to/setup/) template. Made for laptops with undervolting support and NVIDIA GPUs, all provided images are **intended solely for personal use and playground purposes only**.

## System changes

* NVIDIA propietary drivers from [negativo17](https://negativo17.org/repositories/).
* Electronic signtures support with [Autofirma](https://sede.serviciosmin.gob.es/ES-ES/FIRMAELECTRONICA/Paginas/AutoFirma.aspx).
* Undervolt support with [throttled](https://github.com/throttled/throttled)
* A selection of useful [extensions](files/gschema-overrides/zz2.extensions.gschema.override) have been included along with a few modifications to GNOME's [defaults](files/gschema-overrides/zz1.settings.gschema.override).
* Some default pre-installed [rpm packages](recipes/dnf.yml) and [flatpaks](recipes/default-flatpaks.yml) have been removed or added.

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

## Acknowledgments
* [franute's Nimbus-OS](https://github.com/franute/nimbus-os)
* [askpng's Solarpowered](https://github.com/askpng/solarpowered)
* [BlueBuild](https://blue-build.org)
* [Universal Blue](https://github.com/orgs/ublue-os)
