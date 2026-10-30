#!/usr/bin/env bash
# Add the C1 metadata-inject shim to a copy of the MTK camera HAL.
# Idempotent: if the DT_NEEDED entry is already present, leave the file alone.
#
# The Soong genrule sandbox only permits declared tools, so use absolute host
# paths for the two ELF utilities.  Override PATCHELF/READELF if your build
# host keeps them elsewhere.
set -eu

so="${1:?usage: patch_cammeta.sh <libmtkcam_hal_android_device.so>}"
[ -f "$so" ] || { echo "not a file: $so" >&2; exit 1; }

PATCHELF="${PATCHELF:-/usr/bin/patchelf}"
READELF="${READELF:-/usr/bin/readelf}"
[ -x "$PATCHELF" ] || { echo "patchelf not found at $PATCHELF" >&2; exit 1; }
[ -x "$READELF" ] || { echo "readelf not found at $READELF" >&2; exit 1; }

if "$READELF" -d "$so" | grep -q 'libcammeta_inject\.so'; then
  echo "already patched: $so"
  exit 0
fi

"$PATCHELF" --add-needed libcammeta_inject.so "$so"
if ! "$READELF" -d "$so" | grep -q 'libcammeta_inject\.so'; then
  echo "failed to add DT_NEEDED to $so" >&2
  exit 1
fi
echo "patched: $so"
