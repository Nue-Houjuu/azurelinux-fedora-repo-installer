#!/usr/bin/env bash
#
# Azure Linux Fedora Repo Installer
# Desktop Environment Installer
#
# Repository:
# https://github.com/Nue-Houjuu/azurelinux-fedora-repo-installer
#
# This project is NOT affiliated with, endorsed by, or supported by
# Microsoft or the Fedora Project.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

clear

echo "=========================================="
echo " Azure Linux Desktop Installer"
echo "=========================================="
echo

# Root check
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Detect Azure Linux
if [[ ! -f /etc/os-release ]]; then
    echo "Unable to detect operating system."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "azurelinux" ]]; then
    echo "Unsupported operating system."
    echo "This installer only supports Microsoft Azure Linux."
    exit 1
fi

echo "Detected: $PRETTY_NAME"
echo

echo "Available Desktop Environments"
echo
echo " 1) KDE Plasma"
echo " 2) GNOME"
echo " 3) XFCE"
echo " 4) Cinnamon"
echo " 5) MATE"
echo " 6) LXQt"
echo
echo " 0) Exit"
echo

read -rp "Selection: " OPTION

case "$OPTION" in

    1)
        bash "$SCRIPT_DIR/desktop/kde.sh"
        ;;

    2)
        bash "$SCRIPT_DIR/desktop/gnome.sh"
        ;;

    3)
        bash "$SCRIPT_DIR/desktop/xfce.sh"
        ;;

    4)
        bash "$SCRIPT_DIR/desktop/cinnamon.sh"
        ;;

    5)
        bash "$SCRIPT_DIR/desktop/mate.sh"
        ;;

    6)
        bash "$SCRIPT_DIR/desktop/lxqt.sh"
        ;;

    0)
        echo
        echo "Exiting..."
        exit 0
        ;;

    *)
        echo
        echo "Invalid option."
        exit 1
        ;;
esac

echo
echo "=========================================="
echo " Installation completed."
echo "=========================================="
echo
echo "A reboot is recommended."
echo