if [[ ! -f /etc/os-release ]]; then
    echo "Error: Cannot identify the operating system."
    exit 1
fi

source /etc/os-release

if ! command -v dnf >/dev/null 2>&1; then
    echo "Error: DNF is required but was not found."
    exit 1
fi

echo "Detected: ${PRETTY_NAME:-Unknown}"
echo
