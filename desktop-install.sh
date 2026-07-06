#!/usr/bin/env bash
#
# Azure Linux Desktop Installer
# Version 1.0.0
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

clear

echo "=========================================="
echo " Azure Linux Desktop Installer"
echo " Version 1.0.0"
echo "=========================================="
echo

# Root check
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

# Detect Azure Linux
source /etc/os-release

if [[ "$ID" != "azurelinux" ]]; then
    echo "Unsupported operating system."
    exit 1
fi

echo "Detected:"
echo "  $PRETTY_NAME"
echo

echo "Available Desktop Environments"
echo
echo "1) KDE Plasma"
echo "2) XFCE"
echo
echo "0) Exit"
echo

read -rp "Selection: " OPTION

case "$OPTION" in

    1)
        source "$SCRIPT_DIR/desktop/kde.sh"
        ;;

    2)
        source "$SCRIPT_DIR/desktop/xfce.sh"
        ;;

    0)
        echo "Goodbye."
        exit 0
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;

esac

echo
echo "=========================================="
echo "Installation completed."
echo "=========================================="
echo
echo "A reboot is recommended."
echo
