# Licenses & source

This repository distributes prebuilt copies of third-party software so the driver
works out of the box. Each component remains under its own license, and the
corresponding upstream source is linked below.

| Component | License | Upstream source |
|-----------|---------|-----------------|
| foo2zjs / foo2xqx (`foo2xqx`, `foo2xqx-wrapper`, `foo2zjs-pstops`, `arm2hpdl`, PPD) | GPLv2 | https://github.com/OpenPrinting/foo2zjs |
| Ghostscript (`filter/gsbundle/`) | AGPL | https://www.ghostscript.com/ · https://github.com/ArtifexSoftware/ghostpdl |
| GNU sed (`filter/gsed`) | GPLv3 | https://www.gnu.org/software/sed/ |

The bundled binaries were built from the unmodified upstream sources above; the
Ghostscript libraries were relocated with `dylibbundler` but not otherwise altered.
The wrapper scripts (`foo2xqx-cups`, `setup.sh`, `allow-sandbox.sh`) in this
repository are provided under GPLv2 to match foo2zjs.

To obtain the exact upstream source for any GPL/AGPL component, follow the links above.
