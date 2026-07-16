#!/bin/bash
# Fallback: only needed if setup.sh reported the test page failed at the filter stage.
# Relaxes the macOS CUPS print-filter sandbox, then restarts CUPS. Safe & reversible
# (it backs up the config and validates before applying).
set -e
CF=/etc/cups/cups-files.conf
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo: sudo ./allow-sandbox.sh"; exit 1; }
cp "$CF" "$CF.bak.m1005"
TMP="$(mktemp)"; grep -vi '^[[:space:]]*Sandboxing' "$CF" > "$TMP" || true
echo "Sandboxing off" >> "$TMP"; cat "$TMP" > "$CF"; rm -f "$TMP"
/usr/sbin/cupsd -t || { echo "config test failed, restoring"; cat "$CF.bak.m1005" > "$CF"; exit 1; }
launchctl kickstart -k system/org.cups.cupsd
echo "Done. Try printing again."
