# Shared desktop package lists. These are best-effort Fedora package names,
# not a claim that every package is compatible with Azure Linux.
load_desktop_packages() {
    local desktop="$1"
    DESKTOP_PACKAGES=()
    case "$desktop" in
        kde)
            DESKTOP_PACKAGES=(
                plasma-desktop
                plasma-workspace
                plasma-workspace-wayland
                sddm
                konsole
                dolphin
                NetworkManager
            )
            ;;
        gnome)
            DESKTOP_PACKAGES=(
                gnome-shell
                gnome-session
                gnome-terminal
                nautilus
                gdm
                NetworkManager
            )
            ;;
        xfce)
            DESKTOP_PACKAGES=(
                xfce4-session
                xfce4-panel
                xfce4-settings
                xfce4-terminal
                thunar
                lightdm
                lightdm-gtk
                NetworkManager
            )
            ;;
        mate)
            DESKTOP_PACKAGES=(
                mate-desktop
                mate-session-manager
                mate-panel
                mate-terminal
                caja
                lightdm
                lightdm-gtk
                NetworkManager
            )
            ;;
        lxqt)
            DESKTOP_PACKAGES=(
                lxqt-session
                lxqt-panel
                pcmanfm-qt
                qterminal
                sddm
                NetworkManager
            )
            ;;
        *)
            printf 'Unknown desktop: %s\n' "$desktop" >&2
            return 1
            ;;
    esac
}
