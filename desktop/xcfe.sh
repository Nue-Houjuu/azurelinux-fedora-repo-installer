#!/usr/bin/env bash

echo
echo "Installing XFCE..."
echo

dnf group install xfce-desktop -y

dnf install lightdm lightdm-gtk -y

systemctl enable lightdm

systemctl set-default graphical.target

echo
echo "XFCE installed successfully!"
