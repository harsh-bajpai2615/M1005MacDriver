<div align="center">

# 🖨️ HP LaserJet M1005 — macOS Driver

**A working driver for the HP LaserJet M1005 MFP on modern Apple Silicon Macs.**
HP never shipped one that runs on today's macOS — this is a one-command installer that bundles the open-source **foo2zjs / foo2xqx** driver *and* a self-contained copy of **Ghostscript**, so it just works. **No Homebrew, no build steps, nothing else to install.**

![platform](https://img.shields.io/badge/platform-macOS%20(Apple%20Silicon)-000?logo=apple)
![driver](https://img.shields.io/badge/driver-foo2zjs%2Ffoo2xqx-5B5BD6)
![release](https://img.shields.io/github/v/release/harsh-bajpai2615/M1005MacDriver?color=5B5BD6)
![license](https://img.shields.io/badge/license-GPL--2.0-16A34A)

[**⬇ Download the installer**](https://github.com/harsh-bajpai2615/M1005MacDriver/releases/latest) · [Requirements](#requirements) · [Install](#install) · [How it works](#how-it-works) · [Troubleshooting](#troubleshooting)

</div>

---

## Why this exists

The HP LaserJet M1005 MFP is a **host-based (ZjStream/XQX)** printer — it has no PostScript or PCL interpreter of its own, so the built-in macOS AirPrint and Gutenprint drivers can't drive it. HP's own driver was discontinued years ago and never supported Apple Silicon or recent macOS. The only thing that works is the open-source **foo2xqx** driver — but getting it running on a modern Mac normally means compiling from source, installing Ghostscript and GNU sed from Homebrew, and then fighting macOS's mandatory print-filter sandbox, which blocks filters from reaching anything outside the system directories.

This package solves all of that once. Everything the printer needs is compiled, bundled, and placed where the sandbox allows it to run — so on the next Mac it's a single command.

## Requirements

- An **Apple Silicon** Mac (M1/M2/M3/M4 — `arm64`). *Intel Macs are not supported by this build.*
- The printer connected by **USB** and powered on. (The M1005 is USB-only — no network/Wi-Fi.)

## Install

**Option A — download the installer (recommended)**

1. [Download the latest release](https://github.com/harsh-bajpai2615/M1005MacDriver/releases/latest) and unzip it.
2. Open **Terminal**, `cd` into the unzipped folder, and run:

   ```bash
   sudo ./setup.sh
   ```

**Option B — clone the repo**

```bash
git clone https://github.com/harsh-bajpai2615/M1005MacDriver.git
cd hp-m1005-macos-driver
sudo ./setup.sh
```

The installer verifies your Mac is Apple Silicon, installs the self-contained driver, **auto-detects the printer's USB address**, creates the print queue, sets it as default, and prints a test page. After that, just print from any app.

## How it works

- **`foo2xqx`** converts Ghostscript's 1-bit raster into the printer's XQX stream (compiled from [foo2zjs](https://github.com/OpenPrinting/foo2zjs)).
- **Bundled Ghostscript** rasterizes each page — shipped with all of its libraries relinked to load from alongside the binary, plus its resource files, so it needs nothing from Homebrew or `/usr/local`.
- **A small CUPS filter** (`foo2xqx-cups`) ties it together and lives entirely in `/usr/libexec/cups/filter`, the one location macOS lets sandboxed print filters execute from.

Everything is self-contained under `/usr/libexec/cups/filter`, so the driver keeps working regardless of what else you install or remove later.

## Troubleshooting

- **The test page didn't print.** On some macOS versions the print-filter sandbox is stricter. Run the included fallback, then print again:
  ```bash
  sudo ./allow-sandbox.sh
  ```
- **"Could not find an HP LaserJet M1005 on USB."** Make sure it's powered on and the USB cable is connected directly to the Mac (avoid flaky USB-C hubs), then re-run `sudo ./setup.sh`.
- **Intel Mac.** This build is Apple-Silicon only. You'd need to rebuild `foo2xqx` and the Ghostscript bundle for `x86_64`.

## Licenses & source

This package redistributes third-party software under their respective licenses:

- **foo2zjs / foo2xqx** — GPLv2 — <https://github.com/OpenPrinting/foo2zjs>
- **Ghostscript** — AGPL — <https://www.ghostscript.com/>
- **GNU sed** — GPLv3 — <https://www.gnu.org/software/sed/>

See [`LICENSES.md`](LICENSES.md) for details.
