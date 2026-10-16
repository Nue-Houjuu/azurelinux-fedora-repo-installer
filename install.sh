#---------------------------------------
# Operating System Detection
#---------------------------------------

if [[ ! -f /etc/os-release ]]; then
    echo "Error: Cannot identify the operating system."
    exit 1
fi

source /etc/os-release

echo "Detected: ${PRETTY_NAME:-Unknown}"
echo

if ! command -v dnf >/dev/null 2>&1; then
    echo "Error: DNF is required but was not found."
    exit 1
fi

case "${ID:-}" in
    azurelinux)
        INSTALL_FEDORA_REPOS=true
        ;;
    fedora)
        INSTALL_FEDORA_REPOS=false
        echo "Fedora detected. Its official repositories will be preserved."
        ;;
    *)
        echo "WARNING: This operating system is not officially tested."
        echo "Mixing Fedora packages with another distribution can"
        echo "cause dependency conflicts or damage the system."
        echo

        read -rp "Continue anyway? [y/N]: " CONFIRM

        case "$CONFIRM" in
            [Yy]|[Yy][Ee][Ss])
                INSTALL_FEDORA_REPOS=true
                ;;
            *)
                echo "Installation cancelled."
                exit 0
                ;;
        esac
        ;;
esac
