#!/usr/bin/env bash

echo
echo "Installing KDE Plasma..."
echo

dnf group install kde-desktop -y

dnf install sddm -y

systemctl enable sddm

systemctl set-default graphical.target

echo
echo "KDE Plasma installed successfully!"
