#!/usr/bin/env bash
#
# Azure Linux Fedora Repo Installer
#
# Repository:
# https://github.com/Nue-Houjuu/azurelinux-fedora-repo-installer
#
# This project is NOT affiliated with, endorsed by, or supported by
# Microsoft or the Fedora Project.
#

set -e

REPO_URL="https://github.com/Nue-Houjuu/azurelinux-fedora-repo-installer"
RAW_URL="https://raw.githubusercontent.com/Nue-Houjuu/azurelinux-fedora-repo-installer/main"

# Detect if we're running from git or curl
if [[ -d "$(dirname "$0")/repos" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    MODE="local"
else
    MODE="remote"
fi

echo "========================================="
echo " Azure Linux Fedora Repo Installer"
echo "========================================="
echo

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "azurelinux" ]]; then
    echo "Unsupported distribution."
    echo "This installer only supports Microsoft Azure Linux."
    exit 1
fi

echo "Detected: $PRETTY_NAME"

mkdir -p /etc/yum.repos.d/backup
cp -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2>/dev/null || true

echo
echo "Installing Fedora repositories..."

if [[ "$MODE" == "local" ]]; then

    cp "$SCRIPT_DIR/repos/fedora.repo" /etc/yum.repos.d/
    cp "$SCRIPT_DIR/repos/fedora-updates.repo" /etc/yum.repos.d/

else

    curl -fsSL "$RAW_URL/repos/fedora.repo" \
        -o /etc/yum.repos.d/fedora.repo

    curl -fsSL "$RAW_URL/repos/fedora-updates.repo" \
        -o /etc/yum.repos.d/fedora-updates.repo

fi

dnf clean all
dnf makecache

echo
echo "Fedora repositories installed successfully!"
echo
echo "Repository:"
echo "$REPO_URL"
echo
echo "To install a desktop environment run:"
echo
echo "    sudo ./desktop.sh"