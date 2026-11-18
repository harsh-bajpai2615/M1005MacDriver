#!/bin/bash
# HP LaserJet M1005 MFP driver for Apple Silicon macOS: portable installer.
# Self-contained: bundles the foo2xqx driver, Ghostscript, and GNU sed.
# No Homebrew or other tools required on this machine.
#
#   Requirements: Apple Silicon Mac (arm64), printer connected via USB and ON.
#   Run with:     sudo ./setup.sh
set -e

SELF="$(cd "$(dirname "$0")" && pwd)"
DEST="/usr/libexec/cups/filter"
PPDDEST="/Library/Printers/PPDs/Contents/Resources"
PPD="HP-LaserJet_M1005_MFP-foo2xqx.ppd"
PRINTER="HP_LaserJet_M1005"

[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo:  sudo ./setup.sh" >&2; exit 1; }

if [ "$(uname -m)" != "arm64" ]; then
  echo "ERROR: This package is built for Apple Silicon (arm64) Macs." >&2
  echo "This Mac reports '$(uname -m)'. It will not run here." >&2
  exit 1
fi

# Strip the download "quarantine" flag so the bundled binaries can run
xattr -dr com.apple.quarantine "$SELF" 2>/dev/null || true

echo "==> Installing self-contained driver into $DEST"
cp -R "$SELF/filter/." "$DEST/"
xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
for i in foo2xqx foo2xqx-wrapper foo2zjs-pstops gsed arm2hpdl foo2xqx-cups gsbundle; do
  chown -R root:wheel "$DEST/$i"
done
find "$DEST/gsbundle" -type d -exec chmod 755 {} +
find "$DEST/gsbundle" -type f -exec chmod 644 {} +
chmod 755 "$DEST/gsbundle/gs" "$DEST/foo2xqx" "$DEST/foo2xqx-wrapper" \
          "$DEST/foo2zjs-pstops" "$DEST/gsed" "$DEST/arm2hpdl" "$DEST/foo2xqx-cups"

echo "==> Installing PPD"
cp "$SELF/$PPD" "$PPDDEST/"

echo "==> Detecting the printer on USB"
URI="$(lpinfo -v 2>/dev/null | grep -i 'M1005' | grep -i 'usb' | awk '{print $2}' | head -1)"
if [ -z "$URI" ]; then
  echo "ERROR: Could not find an HP LaserJet M1005 on USB." >&2
  echo "Make sure it is plugged in and powered on, then run this again." >&2
  exit 1
fi
echo "    Found: $URI"

echo "==> Registering the printer queue"
lpadmin -x "$PRINTER" 2>/dev/null || true
lpadmin -p "$PRINTER" -E -v "$URI" -P "$PPDDEST/$PPD" -o printer-is-shared=false
cupsenable "$PRINTER"; cupsaccept "$PRINTER"; lpadmin -d "$PRINTER"

echo "==> Printing a test page"
REQ="$(lp -d "$PRINTER" "$SELF/test.ps" 2>&1)"; echo "    $REQ"
JOBNUM="$(printf '%s' "$REQ" | sed -n 's/.*-\([0-9][0-9]*\) .*/\1/p')"
sleep 8

echo
JLOG="$(grep "\[Job $JOBNUM\]" /var/log/cups/error_log 2>/dev/null || true)"
if printf '%s' "$JLOG" | grep -qi "not permitted\|Filter failed\|status 12\|not found"; then
  echo "The test page FAILED at the filter stage. On some macOS versions the print"
  echo "sandbox is stricter. Run the included fallback, then try printing again:"
  echo "    sudo ./allow-sandbox.sh"
else
  echo "SUCCESS: the test page was sent to the printer and should be printing now."
  echo "The M1005 is set as the default printer. Just print normally from any app."
fi
