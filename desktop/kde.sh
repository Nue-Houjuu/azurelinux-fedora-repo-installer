#!/usr/bin/env bash
#
# KDE Plasma Installer
#

set -e

echo
echo "=========================================="
echo " Installing KDE Plasma"
echo "=========================================="
echo

PACKAGES=(
    # Plasma
    plasma-workspace
    plasma-desktop
    plasma-workspace-wallpapers

    # Display Manager
    sddm
    sddm-breeze
    sddm-kcm
    sddm-wayland-plasma

    # Core KDE Applications
    dolphin
    konsole
    kate
    ark
    spectacle
    kwrite

    # Themes
    breeze-icon-theme
    breeze-cursor-theme
)

echo "The following packages will be installed:"
echo

for pkg in "${PACKAGES[@]}"; do
    echo " - $pkg"
done

echo
read -rp "Continue? [Y/n]: " CONFIRM

case "$CONFIRM" in
    [Nn]|[Nn][Oo])
        echo "Installation cancelled."
        exit 0
        ;;
esac

echo
echo "Installing packages..."
echo

dnf install -y "${PACKAGES[@]}"

echo
echo "Enabling SDDM..."

systemctl enable sddm

echo
echo "Setting graphical.target..."

systemctl set-default graphical.target

echo
echo "=========================================="
echo " KDE Plasma installed successfully!"
echo "=========================================="
echo

read -rp "Reboot now? [Y/n]: " REBOOT

case "$REBOOT" in
    [Nn]|[Nn][Oo])
        echo
        echo "Please reboot manually to start KDE Plasma."
        ;;
    *)
        reboot
        ;;
esac
