#!/usr/bin/env bash
#
# Azure Linux Fedora Repo Installer
# Version 1.0.0
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
echo " Azure Linux Fedora Repo Installer"
echo " Version 1.0.0"
echo "=========================================="
echo

#---------------------------------------
# Root Check
#---------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "Error: Please run this script as root."
    echo
    echo "Example:"
    echo "sudo ./install.sh"
    exit 1
fi

#---------------------------------------
# Operating System Detection
#---------------------------------------

if [[ ! -f /etc/os-release ]]; then
    echo "Unable to detect operating system."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "azurelinux" ]]; then
    echo "Unsupported operating system."
    echo
    echo "This installer only supports Microsoft Azure Linux."
    exit 1
fi

echo "Detected:"
echo "  $PRETTY_NAME"
echo

#---------------------------------------
# Verify Installer Files
#---------------------------------------

if [[ ! -f "$SCRIPT_DIR/repos/fedora.repo" ]]; then
    echo "Error:"
    echo "Missing file: repos/fedora.repo"
    exit 1
fi

if [[ ! -f "$SCRIPT_DIR/repos/fedora-updates.repo" ]]; then
    echo "Error:"
    echo "Missing file: repos/fedora-updates.repo"
    exit 1
fi

#---------------------------------------
# Repository Backup
#---------------------------------------

BACKUP_DIR="/etc/yum.repos.d/backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating repository backup..."

mkdir -p "$BACKUP_DIR"

cp -f /etc/yum.repos.d/*.repo "$BACKUP_DIR"/ 2>/dev/null || true

echo "Backup saved to:"
echo "  $BACKUP_DIR"
echo

#---------------------------------------
# Existing Repository Check
#---------------------------------------

if [[ -f /etc/yum.repos.d/fedora.repo ]] || [[ -f /etc/yum.repos.d/fedora-updates.repo ]]; then

    echo "Fedora repositories are already installed."
    echo

    while true; do

        read -rp "Do you want to overwrite them? [y/N]: " OVERWRITE

        case "$OVERWRITE" in

            [Yy]|[Yy][Ee][Ss])

                echo
                echo "Overwriting Fedora repositories..."
                echo
                break
                ;;

            [Nn]|[Nn][Oo]|"")

                echo
                echo "Installation cancelled."
                exit 0
                ;;

            *)

                echo "Please answer y or n."
                ;;

        esac

    done

fi

#---------------------------------------
# Install Fedora Repositories
#---------------------------------------

echo "Installing Fedora repositories..."

cp -f "$SCRIPT_DIR/repos/fedora.repo" /etc/yum.repos.d/
cp -f "$SCRIPT_DIR/repos/fedora-updates.repo" /etc/yum.repos.d/

echo "Done."
echo

#---------------------------------------
# Refresh DNF Cache
#---------------------------------------

echo "Refreshing DNF cache..."

dnf clean all
dnf makecache

echo
echo "=========================================="
echo " Fedora repositories installed successfully!"
echo "=========================================="
echo
echo "Next step:"
echo
echo "Run the Desktop Installer to install KDE,"
echo "GNOME, XFCE, Cinnamon, MATE or LXQt."
echo
echo "    sudo ./desktop-install.sh"
echo
echo "Project:"
echo "https://github.com/Nue-Houjuu/azurelinux-fedora-repo-installer"
echo
