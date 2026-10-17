#!/usr/bin/env bash
# Package list is defined in common.sh and executed by desktop-install.sh.
# Do not run this file directly; use:
# sudo ./desktop-install.sh --desktop kde --enable-fedora-mixing --assumeno
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"
load_desktop_packages kde
printf '%s\n' "${DESKTOP_PACKAGES[@]}"
