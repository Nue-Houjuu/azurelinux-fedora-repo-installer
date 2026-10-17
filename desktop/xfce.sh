#!/usr/bin/env bash
# Package list is defined in common.sh and executed by desktop-install.sh.
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"
load_desktop_packages xfce
printf '%s\n' "${DESKTOP_PACKAGES[@]}"
